import { useEffect, useRef, type CSSProperties } from 'react'
import { isMotionReduced, subscribeMotion } from '@/hooks/use-reduced-motion'

const VERT = `
attribute vec2 p;
void main() { gl_Position = vec4(p, 0.0, 1.0); }
`

const FRAG = `
precision highp float;
uniform vec2  uRes;
uniform float uTime;
uniform float uHeight;
uniform float uFade;
uniform vec3  uBg;
uniform vec3  uCore;
uniform vec3  uEdge;

// --- шум ---
float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}
// Решётка зациклена с периодом 289: координаты не растут со временем,
// и хэш не теряет точность на долго открытой вкладке.
float noise(vec2 p) {
  vec2 i = floor(p), f = fract(p);
  vec2 a = mod(i, 289.0), b = mod(i + 1.0, 289.0);
  f = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(a), hash(vec2(b.x, a.y)), f.x),
             mix(hash(vec2(a.x, b.y)), hash(b), f.x), f.y);
}
float fbm(vec2 p) {
  float v = 0.0, a = 0.5;
  mat2 r = mat2(0.8, -0.6, 0.6, 0.8);
  for (int i = 0; i < 5; i++) {
    p = mod(p, 289.0);
    v += a * noise(p);
    p = r * p * 2.0 + 7.3;
    a *= 0.5;
  }
  return v;
}

void main() {
  vec2 uv = gl_FragCoord.xy / uRes;          // 0..1, y вверх
  float asp = uRes.x / uRes.y;
  vec2 p = vec2(uv.x * asp, uv.y);

  float t = uTime;

  // Дым поднимается вверх + заворачивается (domain warping)
  vec2 q = vec2(fbm(p * 1.6 + vec2(0.0, -t * 0.12)),
                fbm(p * 1.6 + vec2(5.2, -t * 0.10)));
  vec2 r = vec2(fbm(p * 2.2 + 3.0 * q + vec2(1.7, 9.2) + t * 0.06),
                fbm(p * 2.2 + 3.0 * q + vec2(8.3, 2.8) - t * 0.05));
  float n = fbm(p * 1.4 + 2.2 * r + vec2(0.0, -t * 0.08));

  // Высота «линии» дыма: у края экрана — ниже, посередине — языки вверх
  float hump = 0.5 + 0.5 * sin(p.x * 1.7 + t * 0.15 + n * 3.0);
  float top = uHeight * (0.55 + 0.35 * hump) + (n - 0.5) * 0.45 * uHeight * 1.6;
  top += (r.x - 0.5) * 0.22 * uHeight;

  // Плотность: 1 внизу, плавно уходит в 0 к верхней границе
  float d = (1.0 - smoothstep(top - 0.12, top + 0.16, uv.y));
  d = pow(d, 1.1);

  // Ядро светится у кромки дыма и гаснет к низу: без этого низ — сплошная заливка
  float glow = smoothstep(top - 0.95 * uHeight, top - 0.02, uv.y);
  float body = smoothstep(0.25, 0.9, d);

  // Цвет: кромка — красная, ниже — бордовая, у самого низа — фон
  vec3 col = mix(uBg, uEdge, smoothstep(0.0, 0.55, d) * (0.35 + 0.65 * glow));
  col = mix(col, uCore, body * glow * glow);

  // Лёгкий тёмный «ожог» по краям завитков
  col *= 1.0 - 0.12 * smoothstep(0.35, 0.6, abs(n - r.y)) * (1.0 - smoothstep(0.7, 1.0, d));

  // Растворение в фон у нижнего края — вместо CSS-маски на слое с WebGL
  if (uFade > 0.0) col = mix(uBg, col, clamp(uv.y / uFade, 0.0, 1.0));

  // Дизеринг, чтобы не было бандинга на градиенте
  col += (hash(gl_FragCoord.xy + fract(t)) - 0.5) / 255.0;

  gl_FragColor = vec4(col, 1.0);
}
`

type Props = {
  background?: string
  core?: string
  edge?: string
  height?: number
  // Share of the canvas height, at the bottom, that dissolves into the background.
  fade?: number
  speed?: number
  className?: string
  style?: CSSProperties
}
function hexToRgb(hex: string) {
  const h = hex.replace('#', '')
  const v = parseInt(h.length === 3 ? h.replace(/(.)/g, '$1$1') : h, 16)
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255].map((c) => c / 255)
}
export default function FlameBackground({
  background = '#080808',
  core = '#ff253e',
  edge = '#a60e27',
  height = 0.5,
  fade = 0,
  speed = 1,
  className,
  style,
}: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const gl = canvas.getContext('webgl', { antialias: false, alpha: false })
    if (!gl) return
    // Everything tied to the GL context is rebuilt after a context loss.
    let program: WebGLProgram | null = null
    let buffer: WebGLBuffer | null = null
    let uniforms: Record<string, WebGLUniformLocation | null> = {}
    const compile = (type: number, source: string) => {
      const shader = gl.createShader(type)
      if (!shader) return null
      gl.shaderSource(shader, source)
      gl.compileShader(shader)
      if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
        gl.deleteShader(shader)
        return null
      }
      return shader
    }
    const setup = () => {
      const vertex = compile(gl.VERTEX_SHADER, VERT)
      const fragment = compile(gl.FRAGMENT_SHADER, FRAG)
      const next = gl.createProgram()
      if (!vertex || !fragment || !next) {
        if (vertex) gl.deleteShader(vertex)
        if (fragment) gl.deleteShader(fragment)
        if (next) gl.deleteProgram(next)
        return false
      }
      gl.attachShader(next, vertex)
      gl.attachShader(next, fragment)
      gl.linkProgram(next)
      gl.deleteShader(vertex)
      gl.deleteShader(fragment)
      if (!gl.getProgramParameter(next, gl.LINK_STATUS)) {
        gl.deleteProgram(next)
        return false
      }
      program = next
      gl.useProgram(program)
      buffer = gl.createBuffer()
      gl.bindBuffer(gl.ARRAY_BUFFER, buffer)
      gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 3, -1, -1, 3]), gl.STATIC_DRAW)
      const location = gl.getAttribLocation(program, 'p')
      gl.enableVertexAttribArray(location)
      gl.vertexAttribPointer(location, 2, gl.FLOAT, false, 0, 0)
      uniforms = Object.fromEntries(
        ['uRes', 'uTime', 'uHeight', 'uFade', 'uBg', 'uCore', 'uEdge'].map((name) => [
          name,
          gl.getUniformLocation(program!, name),
        ]),
      )
      gl.uniform1f(uniforms.uHeight, Math.max(0, Math.min(1, height)))
      gl.uniform1f(uniforms.uFade, Math.max(0, Math.min(1, fade)))
      gl.uniform3fv(uniforms.uBg, hexToRgb(background))
      gl.uniform3fv(uniforms.uCore, hexToRgb(core))
      gl.uniform3fv(uniforms.uEdge, hexToRgb(edge))
      return true
    }
    if (!setup()) return
    // Either the OS setting or the site's pause switch freezes the flame.
    let reduced = isMotionReduced()
    let raf = 0,
      time = 0,
      last = performance.now(),
      visible = true,
      lost = false
    const draw = () => {
      if (lost || !program) return
      gl.uniform2f(uniforms.uRes, canvas.width, canvas.height)
      gl.uniform1f(uniforms.uTime, time + 20)
      gl.drawArrays(gl.TRIANGLES, 0, 3)
    }
    const frame = (now: number) => {
      raf = 0
      if (!visible || document.hidden || lost) return
      if (!reduced) time += Math.min(0.05, (now - last) / 1000) * speed
      last = now
      draw()
      if (!reduced && speed !== 0) raf = requestAnimationFrame(frame)
    }
    const sync = () => {
      cancelAnimationFrame(raf)
      raf = 0
      last = performance.now()
      if (visible && !document.hidden && !lost) raf = requestAnimationFrame(frame)
    }
    const resize = () => {
      canvas.width = Math.max(2, Math.floor(canvas.clientWidth * 0.5))
      canvas.height = Math.max(2, Math.floor(canvas.clientHeight * 0.5))
      if (!lost) gl.viewport(0, 0, canvas.width, canvas.height)
      draw()
    }
    const ro = new ResizeObserver(resize)
    ro.observe(canvas)
    const io = new IntersectionObserver(([entry]) => {
      visible = entry.isIntersecting
      sync()
    })
    io.observe(canvas)
    // A lost context leaves a blank (white in Chrome) canvas: hide it until it comes back.
    const contextLost = (event: Event) => {
      event.preventDefault()
      lost = true
      program = null
      cancelAnimationFrame(raf)
      canvas.style.visibility = 'hidden'
    }
    const contextRestored = () => {
      lost = false
      if (!setup()) return
      canvas.style.visibility = ''
      resize()
      sync()
    }
    canvas.addEventListener('webglcontextlost', contextLost)
    canvas.addEventListener('webglcontextrestored', contextRestored)
    document.addEventListener('visibilitychange', sync)
    const unsubscribeMotion = subscribeMotion(() => {
      reduced = isMotionReduced()
      sync()
    })
    resize()
    sync()
    return () => {
      cancelAnimationFrame(raf)
      ro.disconnect()
      io.disconnect()
      canvas.removeEventListener('webglcontextlost', contextLost)
      canvas.removeEventListener('webglcontextrestored', contextRestored)
      document.removeEventListener('visibilitychange', sync)
      unsubscribeMotion()
      if (!lost) {
        gl.deleteProgram(program)
        gl.deleteBuffer(buffer)
      }
    }
  }, [background, core, edge, height, fade, speed])
  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      className={className}
      style={{
        position: 'absolute',
        inset: 0,
        width: '100%',
        height: '100%',
        display: 'block',
        pointerEvents: 'none',
        background,
        ...style,
      }}
    />
  )
}
