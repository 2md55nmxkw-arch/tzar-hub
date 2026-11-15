import type { ThemeRegistration } from 'shiki/core'

// Brand themes: near-black or paper background, red keywords, warm amber
// functions and soft red strings. Kept small on purpose — a handful of scopes
// covers the languages the site highlights.

const keywordScopes = [
  'keyword',
  'storage',
  'storage.type',
  'keyword.control',
  'keyword.operator.new',
  'keyword.other',
]

const functionScopes = [
  'entity.name.function',
  'support.function',
  'meta.function-call',
  'entity.name.function.call',
  'variable.function',
]

const typeScopes = [
  'entity.name.type',
  'entity.name.class',
  'entity.other.inherited-class',
  'support.type',
  'support.class',
  'entity.name.namespace',
]

const constantScopes = [
  'constant.numeric',
  'constant.language',
  'constant.character',
  'support.constant',
]

export const darkTheme = {
  name: 'tzar-dark',
  type: 'dark',
  colors: {
    'editor.background': '#080808',
    'editor.foreground': '#ededed',
  },
  tokenColors: [
    {
      scope: ['comment', 'punctuation.definition.comment'],
      settings: { foreground: '#6f6f6d', fontStyle: 'italic' },
    },
    {
      scope: ['string', 'constant.other.symbol', 'markup.underline.link'],
      settings: { foreground: '#ffb3b8' },
    },
    { scope: constantScopes, settings: { foreground: '#f2a08f' } },
    { scope: keywordScopes, settings: { foreground: '#ff6b75' } },
    { scope: functionScopes, settings: { foreground: '#ffcf8a' } },
    { scope: typeScopes, settings: { foreground: '#ff9aa2' } },
    { scope: ['entity.name.tag'], settings: { foreground: '#ff6b75' } },
    { scope: ['entity.other.attribute-name'], settings: { foreground: '#ffcf8a' } },
    { scope: ['variable.parameter'], settings: { foreground: '#cfcfcc' } },
    { scope: ['variable', 'variable.other'], settings: { foreground: '#e6e6e4' } },
    { scope: ['punctuation', 'meta.brace', 'meta.delimiter'], settings: { foreground: '#85858a' } },
    { scope: ['markup.heading'], settings: { foreground: '#ffffff', fontStyle: 'bold' } },
    { scope: ['invalid', 'invalid.illegal'], settings: { foreground: '#ff3b3b' } },
  ],
} satisfies ThemeRegistration

export const lightTheme = {
  name: 'tzar-light',
  type: 'light',
  colors: {
    'editor.background': '#ffffff',
    'editor.foreground': '#121212',
  },
  tokenColors: [
    {
      scope: ['comment', 'punctuation.definition.comment'],
      settings: { foreground: '#7c7c7a', fontStyle: 'italic' },
    },
    {
      scope: ['string', 'constant.other.symbol', 'markup.underline.link'],
      settings: { foreground: '#a33a3f' },
    },
    { scope: constantScopes, settings: { foreground: '#8a4b12' } },
    { scope: keywordScopes, settings: { foreground: '#c8102e' } },
    { scope: functionScopes, settings: { foreground: '#8a5a00' } },
    { scope: typeScopes, settings: { foreground: '#a3121f' } },
    { scope: ['entity.name.tag'], settings: { foreground: '#c8102e' } },
    { scope: ['entity.other.attribute-name'], settings: { foreground: '#8a5a00' } },
    { scope: ['variable.parameter'], settings: { foreground: '#3a3a3a' } },
    { scope: ['variable', 'variable.other'], settings: { foreground: '#121212' } },
    { scope: ['punctuation', 'meta.brace', 'meta.delimiter'], settings: { foreground: '#6b6b6b' } },
    { scope: ['markup.heading'], settings: { foreground: '#080808', fontStyle: 'bold' } },
    { scope: ['invalid', 'invalid.illegal'], settings: { foreground: '#b00020' } },
  ],
} satisfies ThemeRegistration
