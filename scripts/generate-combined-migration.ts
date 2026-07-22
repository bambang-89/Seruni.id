/**
 * Generate Combined SQL Migration for Supabase
 * Combines all migration files in chronological order
 */

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function main() {
  console.log("Generating combined migration SQL...\n");

  const migrationsDir = path.join(__dirname, "../supabase/migrations");
  const outputPath = path.join(__dirname, "../docs/supabase_migration_all.sql");

  // Get all SQL files
  const files = fs.readdirSync(migrationsDir)
    .filter(f => f.endsWith('.sql'))
    .sort();

  console.log(`Found ${files.length} migration files\n`);

  const header = `-- ============================================
-- SUPABASE MIGRATION - ALL IN ONE
-- Generated: ${new Date().toISOString()}
-- Total files: ${files.length}
-- ============================================

-- NOTE: Run this in Supabase SQL Editor
-- This file contains all schema definitions

`;

  let content = header;
  let totalSize = 0;

  for (const file of files) {
    console.log(`Processing: ${file}`);
    const filePath = path.join(migrationsDir, file);
    const fileContent = fs.readFileSync(filePath, "utf-8");
    totalSize += fileContent.length;

    content += `\n\n-- ============================================\n`;
    content += `-- FILE: ${file}\n`;
    content += `-- ============================================\n\n`;
    content += fileContent;
  }

  // Write to file
  fs.writeFileSync(outputPath, content, "utf-8");

  const sizeMB = (content.length / 1024 / 1024).toFixed(2);
  console.log(`\nTotal migration SQL generated: ${outputPath}`);
  console.log(`File size: ${sizeMB} MB`);
  console.log(`Total migrations: ${files.length}`);
}

main();
