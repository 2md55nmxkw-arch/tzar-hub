import {
  CodeBlock,
  CodeBlockActions,
  CodeBlockContent,
  CodeBlockCopyButton,
  CodeBlockHeader,
  CodeBlockLine,
  CodeBlockTitle,
} from '@/components/ui/code-block'
import { useHighlightedCode } from '@/hooks/use-highlighted-code'
import { TZAR_LOADER } from './tzar-content'

// Shiki and the Lua grammar are only needed here, so Quick start loads this
// module lazily instead of putting the highlighter in the main bundle.
export default function LoaderCode({
  code = TZAR_LOADER,
  title = 'loader.lua',
}: {
  code?: string
  title?: string
}) {
  const lines = useHighlightedCode(code, 'lua')

  return (
    <CodeBlock className="mt-3">
      <CodeBlockHeader>
        <CodeBlockTitle>{title}</CodeBlockTitle>
        <CodeBlockActions>
          <CodeBlockCopyButton value={code} />
        </CodeBlockActions>
      </CodeBlockHeader>
      <CodeBlockContent>
        {lines.map((line, index) => (
          <CodeBlockLine key={index}>{line}</CodeBlockLine>
        ))}
      </CodeBlockContent>
    </CodeBlock>
  )
}
