# Rails Migration Index Checker

This GitHub Action ensures that all foreign key columns (columns ending in `_id`) in your Rails migrations have corresponding indexes. This helps maintain database performance by preventing common indexing oversights during development.

## Features

### 1. Comprehensive Migration Syntax Detection
The checker recognizes foreign keys defined in multiple formats:
```ruby
# Standard add_column
add_column :users, :company_id, :bigint

# Within create_table blocks
create_table :users do |t|
  t.references :company
  t.belongs_to :organization
  t.column :department_id, :integer
end
```

### 2. Smart Index Detection
Indexes can be recognized in various formats:

- Single column indexes:
```ruby
add_index :users, :company_id
```

- Composite indexes (foreign key can be part of a larger index):
```ruby
add_index :users, [:company_id, :department_id]
```

### 3. Schema-Aware
The checker won't fail if an index already exists in your schema.rb:
- Reads current schema.rb to understand existing indexes
- Prevents duplicate index warnings
- Handles both simple and composite indexes in the schema

### 4. Cross-Migration Support
Handles indexes that might be added in separate migrations within the same PR:
- Tracks all migrations being added/modified
- Understands relationships between migrations
- Won't fail if an index is added in a different migration file in the same PR

## Usage

1. Add this file to `.github/workflows/check_migration_indexes.yml`
2. The action will automatically run on any PR that includes changes to files in `db/migrate/`

## Example Output

When it finds a missing index:
```
Error: Missing index for foreign key column 'company_id' in table 'users'
```

## Configuration

The action runs automatically with these triggers:
```yaml
on:
  pull_request:
    paths:
      - 'db/migrate/**.rb'
```

## Common Scenarios

### ✅ Will Pass
```ruby
# Migration 1
class AddCompanyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :bigint
    add_index :users, :company_id
  end
end

# Migration 2
class AddCompanyAndDepartment < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :bigint
    add_column :users, :department_id, :bigint
    add_index :users, [:company_id, :department_id]
  end
end
```

### ❌ Will Fail
```ruby
class AddCompanyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :bigint
    # Missing index!
  end
end
```

## Implementation Details

### Error Detection
- Scans for `add_column` statements ending in `_id`
- Checks for corresponding `add_index` statements
- Verifies against existing schema.rb
- Handles multi-column indexes

### Parsing Strategy
The checker uses a line-by-line parsing strategy with context awareness:
- Tracks current table context in `create_table` blocks
- Maintains sets of needed and defined indexes
- Cross-references against schema.rb
- Handles various syntax patterns through regex matching

## Best Practices

1. Always add indexes in the same migration where you add the foreign key
2. Use composite indexes when you frequently query on multiple columns together
3. Consider using `references` with `index: true` for cleaner migrations:
```ruby
add_reference :users, :company, index: true
```

## Limitations

1. The checker only looks for columns ending in `_id`
2. It assumes standard Rails migration syntax
3. May not catch extremely complex or non-standard migration patterns
4. Doesn't analyze index effectiveness or suggest optimizations

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is available as open source under the terms of the MIT License.
