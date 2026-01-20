#!/usr/bin/env node

import { glob } from 'glob';
import fs from 'fs';
import path from 'path';

// Simple test for context package generation
const generator = {
  findRelatedFiles(feature) {
    const patterns = {
      character: {
        components: [
          '**/Character*.{ts,tsx}',
          '**/*[Cc]haracter*.{ts,tsx}'
        ],
        apis: [
          'pages/api/characters/**/*.{ts,tsx}',
          'pages/api/images/character*.{ts,tsx}'
        ],
        types: [
          'types/*[Cc]haracter*.{ts,tsx}'
        ]
      },
      batch: {
        components: [
          '**/Batch*.{ts,tsx}',
          '**/*[Bb]atch*.{ts,tsx}'
        ],
        apis: [
          'pages/api/batch/**/*.{ts,tsx}'
        ],
        types: [
          'types/*[Bb]atch*.{ts,tsx}'
        ]
      }
    };

    const relatedFiles = {
      components: [],
      apis: [],
      types: [],
      hooks: []
    };

    const featurePatterns = patterns[feature.toLowerCase()] || {};

    Object.entries(featurePatterns).forEach(([category, patternList]) => {
      patternList.forEach(pattern => {
        const files = glob.sync(pattern, { cwd: process.cwd() });
        relatedFiles[category].push(...files);
      });
    });

    return relatedFiles;
  },

  generateContextPackage(feature) {
    const relatedFiles = this.findRelatedFiles(feature);

    const packageContent = {
      feature,
      timestamp: new Date().toISOString(),
      components: [],
      apis: [],
      types: [],
      hooks: []
    };

    // Extract basic file info
    Object.entries(relatedFiles).forEach(([category, files]) => {
      files.forEach(file => {
        packageContent[category].push({
          file: path.relative(process.cwd(), file)
        });
      });
    });

    return packageContent;
  },

  renderContextPackage(packageContent) {
    let markdown = `# ${packageContent.feature} Context Package\n\n`;
    markdown += `*Generated on ${packageContent.timestamp}*\n\n`;

    if (packageContent.components.length > 0) {
      markdown += `## Components (${packageContent.components.length})\n\n`;
      packageContent.components.forEach(comp => {
        markdown += `- \`${comp.file}\`\n`;
      });
      markdown += '\n';
    }

    if (packageContent.apis.length > 0) {
      markdown += `## APIs (${packageContent.apis.length})\n\n`;
      packageContent.apis.forEach(api => {
        markdown += `- \`${api.file}\`\n`;
      });
      markdown += '\n';
    }

    if (packageContent.types.length > 0) {
      markdown += `## Types (${packageContent.types.length})\n\n`;
      packageContent.types.forEach(type => {
        markdown += `- \`${type.file}\`\n`;
      });
      markdown += '\n';
    }

    return markdown;
  }
};

// Test
const feature = process.argv[2] || 'character';
const outputDir = process.argv[3] || '.claude/context-packages';

console.log(`Generating context package for: ${feature}`);

const packageContent = generator.generateContextPackage(feature);
const markdown = generator.renderContextPackage(packageContent);

// Create output directory
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// Write file
const outputFile = path.join(outputDir, `${feature}-complete.md`);
fs.writeFileSync(outputFile, markdown);

console.log(`Generated: ${outputFile}`);
console.log(`Components: ${packageContent.components.length}`);
console.log(`APIs: ${packageContent.apis.length}`);
console.log(`Types: ${packageContent.types.length}`);