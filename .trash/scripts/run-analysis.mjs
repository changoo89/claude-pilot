#!/usr/bin/env node

/**
 * Analysis Runner
 *
 * Simple wrapper to run analysis tools without CLI dependencies
 */

import TypeScriptAnalyzer from './analyze-typescript.mjs';
import ComponentAnalyzer from './component-analyzer.mjs';
import SmartImportGenerator from './smart-import-generator.mjs';

// Get command line arguments
const args = process.argv.slice(2);
const command = args[0] || 'help';
const pattern = args[1] || '**/*.{ts,tsx}';

console.log(`Running analysis: ${command}`);

switch (command) {
  case 'typescript':
  case 'ts':
    {
      const analyzer = new TypeScriptAnalyzer();
      const analyses = analyzer.analyzeFiles(pattern);

      if (args.includes('--summary')) {
        const summary = analyzer.generateSummary(analyses);
        console.log('\n## Analysis Summary');
        console.log(`- Total Files: ${summary.totalFiles}`);
        console.log(`- Total Interfaces: ${summary.totalInterfaces}`);
        console.log(`- Total Components: ${summary.totalComponents}`);
      } else {
        console.log(JSON.stringify(analyses, null, 2));
      }
    }
    break;

  case 'component':
  case 'comp':
    {
      // Simple component scan
      const { glob } = await import('glob');
      const files = glob.sync(pattern);
      console.log('\n## Components Found');
      files.forEach(file => {
        console.log(`- ${file}`);
      });
      console.log(`\nTotal: ${files.length} components`);
    }
    break;

  case 'import':
  case 'imports':
    {
      const generator = new SmartImportGenerator();
      const report = generator.analyzeAll();

      console.log('\n## Import Analysis Report');
      console.log(`- Total Files: ${report.summary.totalFiles}`);
      console.log(`- Total Imports: ${report.summary.totalImports}`);
      console.log(`- Circular Dependencies: ${report.summary.circularDependencies}`);

      if (report.recommendations.length > 0) {
        console.log('\n### Recommendations');
        report.recommendations.forEach(rec => {
          console.log(`- ${rec.file}: ${rec.type}`);
        });
      }
    }
    break;

  case 'context':
    {
      const { glob } = await import('glob');
      const fs = await import('fs');
      const path = await import('path');

      const feature = args[1] || 'character';
      const outputDir = '.claude/context-packages';

      console.log(`Generating context package for: ${feature}`);

      // Simple pattern matching
      const patterns = {
        character: ['**/*[Cc]haracter*', 'components/**/Character*'],
        batch: ['**/*[Bb]atch*', 'pages/api/batch/**'],
        image: ['**/*[Ii]mage*', 'pages/api/images/**']
      };

      const relatedFiles = {
        components: [],
        apis: []
      };

      const featurePatterns = patterns[feature] || patterns.character;

      for (const pattern of featurePatterns) {
        const files = glob.sync(pattern);
        files.forEach(file => {
          if (file.includes('components')) {
            relatedFiles.components.push(file);
          } else if (file.includes('pages/api')) {
            relatedFiles.apis.push(file);
          }
        });
      }

      const markdown = generateContextPackage(feature, relatedFiles);

      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }

      const outputFile = path.join(outputDir, `${feature}-complete.md`);
      fs.writeFileSync(outputFile, markdown);

      console.log(`Generated: ${outputFile}`);
      console.log(`Components: ${relatedFiles.components.length}`);
      console.log(`APIs: ${relatedFiles.apis.length}`);
    }
    break;

  default:
    console.log(`
Usage: node run-analysis.mjs <command> [pattern]

Commands:
  ts, typescript    - Analyze TypeScript files
  comp, component   - List components
  import, imports   - Analyze imports
  context          - Generate context package

Examples:
  node run-analysis.mjs ts "components/**/*.tsx" --summary
  node run-analysis.mjs comp "components/**/*.tsx"
  node run-analysis.mjs context character
    `);
}

function generateContextPackage(feature, files) {
  let markdown = `# ${feature} Context Package\n\n`;
  markdown += `*Generated on ${new Date().toISOString()}*\n\n`;

  if (files.components.length > 0) {
    markdown += `## Components (${files.components.length})\n\n`;
    files.components.forEach(file => {
      markdown += `- \`${file}\`\n`;
    });
    markdown += '\n';
  }

  if (files.apis.length > 0) {
    markdown += `## APIs (${files.apis.length})\n\n`;
    files.apis.forEach(file => {
      markdown += `- \`${file}\`\n`;
    });
    markdown += '\n';
  }

  return markdown;
}