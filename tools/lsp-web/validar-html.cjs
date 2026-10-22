// Valida solo el texto recibido. No carga configuración ni plugins del proyecto.
const { HtmlValidate } = require('html-validate');

const validator = new HtmlValidate({
  root: true,
  extends: [],
  elements: ['html5'],
  rules: {
    'attr-spacing': 'error',
    'close-attr': 'error',
    'close-order': 'error',
    'element-permitted-content': 'error',
    'element-permitted-occurrences': 'error',
    'element-required-attributes': 'error',
    'no-dup-attr': 'error',
    'no-dup-id': 'error',
    'no-unknown-attributes': 'error',
    'no-unknown-elements': ['error', { exclude: ['*-*'] }],
    'script-element': 'error',
    'void-content': 'error',
  },
});

async function main() {
  process.stdin.setEncoding('utf8');
  let source = '';
  for await (const chunk of process.stdin) source += chunk;
  const report = await validator.validateString(source);
  // html-validate usa offsets UTF-16; Neovim espera columnas en bytes UTF-8.
  const position = (offset) => {
    const prefix = source.slice(0, offset);
    const start = prefix.lastIndexOf('\n') + 1;
    return {
      line: (prefix.match(/\n/g) || []).length,
      column: Buffer.byteLength(prefix.slice(start), 'utf8'),
    };
  };
  const diagnostics = report.results.flatMap((result) => result.messages.map((item) => {
    const offset = Math.max(0, item.offset ?? 0);
    return {
      start: position(offset),
      end: position(Math.min(source.length, offset + Math.max(1, item.size ?? 1))),
      message: item.message,
      code: item.ruleId,
      severity: item.severity,
    };
  }));
  process.stdout.write(JSON.stringify(diagnostics));
}

main().catch(() => {
  // No reproducir el contenido del archivo en mensajes de error del proceso.
  process.stderr.write('No se pudo ejecutar la validación HTML local.\n');
  process.exitCode = 2;
});
