#!/usr/bin/env node

/**
 * Simple Code Analyzer
 *
 * Analyzes TypeScript files without external dependencies
 */

import fs from 'fs';
import path from 'path';
import { glob } from 'glob';

class SimpleAnalyzer {
  constructor() {
    this.components = [];
    this.apis = [];
    this.types = [];
    this.imports = new Map();
  }

  /**
   * Find all files by pattern
   */
  findFiles(pattern) {
    return glob.sync(pattern, {
      ignore: ['node_modules/**', '.next/**', 'out/**']
    });
  }

  /**
   * Analyze a file for basic information
   */
  analyzeFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const info = {
      path: filePath,
      relative: path.relative(process.cwd(), filePath),
      exports: [],
      imports: [],
      isComponent: false,
      isAPI: false,
      isType: false,
      hasHooks: false,
      hasJSX: false
    };

    // Check if it's a component
    if (filePath.includes('components/') && filePath.endsWith('.tsx')) {
      info.isComponent = true;
      this.components.push(info);
    }

    // Check if it's an API
    if (filePath.includes('pages/api/') && (filePath.endsWith('.ts') || filePath.endsWith('.tsx'))) {
      info.isAPI = true;
      this.apis.push(info);
    }

    // Check if it's a type file
    if (filePath.includes('types/') && filePath.endsWith('.ts')) {
      info.isType = true;
      this.types.push(info);
    }

    // Extract exports
    const exportMatches = content.match(/export\s+(?:default\s+)?(?:const|function|class|interface|type)\s+(\w+)/g);
    if (exportMatches) {
      exportMatches.forEach(match => {
        const name = match.match(/(\w+)$/)?.[1];
        if (name) {
          info.exports.push(name);
        }
      });
    }

    // Extract imports
    const importMatches = content.match(/import\s+.*?\s+from\s+['"]([^'"]+)['"]/g);
    if (importMatches) {
      importMatches.forEach(match => {
        const source = match.match(/from\s+['"]([^'"]+)['"]/)?.[1];
        if (source) {
          info.imports.push(source);
        }
      });
    }

    // Check for React hooks
    if (content.includes('useState') || content.includes('useEffect') || content.includes('useCallback')) {
      info.hasHooks = true;
    }

    // Check for JSX
    if (content.includes('<') && content.includes('/>') && (content.includes('className') || content.includes('return'))) {
      info.hasJSX = true;
    }

    return info;
  }

  /**
   * Analyze all files matching pattern
   */
  analyze(pattern = '**/*.{ts,tsx}') {
    const files = this.findFiles(pattern);
    console.log(`Analyzing ${files.length} files...`);

    files.forEach(file => {
      this.analyzeFile(file);
    });

    return this.generateReport();
  }

  /**
   * Generate analysis report
   */
  generateReport() {
    return {
      summary: {
        totalComponents: this.components.length,
        totalAPIs: this.apis.length,
        totalTypes: this.types.length
      },
      components: this.components,
      apis: this.apis,
      types: this.types
    };
  }

  /**
   * Generate context package for a feature
   */
  generateContextPackage(feature) {
    const patterns = {
      character: {
        files: ['**/*[Cc]haracter*', '**/*character*'],
        exclude: []
      },
      batch: {
        files: ['**/*[Bb]atch*', '**/*batch*'],
        exclude: []
      },
      image: {
        files: ['**/*[Ii]mage*', '**/*image*'],
        exclude: ['**/node_modules/**']
      }
    };

    const pattern = patterns[feature] || patterns.character;
    const allFiles = [];

    pattern.files.forEach(p => {
      const files = this.findFiles(p);
      allFiles.push(...files.filter(f => !pattern.exclude.some(ex => f.includes(ex))));
    });

    const context = {
      feature,
      components: allFiles.filter(f => f.includes('components/')),
      apis: allFiles.filter(f => f.includes('pages/api/')),
      types: allFiles.filter(f => f.includes('types/')),
      libs: allFiles.filter(f => f.includes('lib/')),
      pages: allFiles.filter(f => f.includes('pages/') && !f.includes('/api/'))
    };

    return this.renderContextPackage(context);
  }

  /**
   * Render context package as markdown
   */
  renderContextPackage(context) {
    let markdown = `# ${context.feature} Context Package\n\n`;
    markdown += `*Generated on ${new Date().toISOString()}*\n\n`;

    if (context.components.length > 0) {
      markdown += `## Components (${context.components.length})\n\n`;
      context.components.forEach(file => {
        const name = path.basename(file, path.extname(file));
        markdown += `- \`${name}\` - \`${file}\`\n`;
      });
      markdown += '\n';
    }

    if (context.apis.length > 0) {
      markdown += `## APIs (${context.apis.length})\n\n`;
      context.apis.forEach(file => {
        const name = path.basename(file, path.extname(file));
        markdown += `- \`${name}\` - \`${file}\`\n`;
      });
      markdown += '\n';
    }

    if (context.types.length > 0) {
      markdown += `## Types (${context.types.length})\n\n`;
      context.types.forEach(file => {
        const name = path.basename(file, path.extname(file));
        markdown += `- \`${name}\` - \`${file}\`\n`;
      });
      markdown += '\n';
    }

    if (context.libs.length > 0) {
      markdown += `## Libraries (${context.libs.length})\n\n`;
      context.libs.forEach(file => {
        const name = path.basename(file, path.extname(file));
        markdown += `- \`${name}\` - \`${file}\`\n`;
      });
      markdown += '\n';
    }

    return markdown;
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const command = args[0] || 'analyze';
  const pattern = args[1] || '**/*.{ts,tsx}';

  const analyzer = new SimpleAnalyzer();

  switch (command) {
    case 'analyze':
    case 'a':
      const report = analyzer.analyze(pattern);
      console.log('\n=== Analysis Report ===\n');
      console.log(`Components: ${report.summary.totalComponents}`);
      console.log(`APIs: ${report.summary.totalAPIs}`);
      console.log(`Types: ${report.summary.totalTypes}`);
      console.log('\nUse "components", "apis", or "types" to see details');
      break;

    case 'components':
    case 'comp':
      analyzer.analyze('components/**/*.{ts,tsx}');
      console.log('\n=== Components ===\n');
      analyzer.components.forEach(comp => {
        console.log(`- ${comp.relative}`);
        console.log(`  Exports: ${comp.exports.join(', ')}`);
        console.log(`  Hooks: ${comp.hasHooks ? 'Yes' : 'No'}`);
        console.log();
      });
      break;

    case 'apis':
    case 'api':
      analyzer.analyze('pages/api/**/*.{ts,tsx}');
      console.log('\n=== API Endpoints ===\n');
      analyzer.apis.forEach(api => {
        console.log(`- ${api.relative}`);
        console.log(`  Exports: ${api.exports.join(', ')}`);
        console.log();
      });
      break;

    case 'types':
    case 't':
      analyzer.analyze('types/**/*.ts');
      console.log('\n=== Types ===\n');
      analyzer.types.forEach(type => {
        console.log(`- ${type.relative}`);
        console.log(`  Exports: ${type.exports.join(', ')}`);
        console.log();
      });
      break;

    case 'context':
    case 'c':
      const feature = args[1] || 'character';
      const contextPackage = analyzer.generateContextPackage(feature);

      const outputDir = '.claude/context-packages';
      if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
      }

      const outputFile = path.join(outputDir, `${feature}-complete.md`);
      fs.writeFileSync(outputFile, contextPackage);

      console.log(`Generated: ${outputFile}`);
      console.log(`Feature: ${feature}`);
      break;

    case 'help':
    case 'h':
      console.log(`
Usage: node simple-analyzer.mjs <command> [pattern]

Commands:
  analyze, a       - Analyze all files (default)
  components, comp - List all components
  apis, api       - List all API endpoints
  types, t        - List all type files
  context, c      - Generate context package

Examples:
  node simple-analyzer.mjs
  node simple-analyzer.mjs components
  node simple-analyzer.mjs context character
  node simple-analyzer.mjs context batch
      `);
      break;

    default:
      console.log(`Unknown command: ${command}`);
      console.log('Use "help" to see available commands');
  }
}

export default SimpleAnalyzer;