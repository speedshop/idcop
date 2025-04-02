# Rails Migration Index Checker

This GitHub Action ensures that all foreign key columns in your Rails application have corresponding database indexes. It checks your `schema.rb` to catch cases where foreign keys might be created or modified across multiple migrations.

UNRELATED README CHANGE

## Why Use This?

Foreign keys without indexes can cause significant performance issues:
- Slow JOIN operations
- Poor query performance on foreign key lookups
- Potential table scans instead of index scans

## Features

### 1. Comprehensive Foreign Key Detection
Detects foreign keys defined in various ways:

```ruby
# Direct column definitions
t.bigint :company_id
t.integer :user_id

# Rails associations
t.references :organization
t.belongs_to :department

# Columns changed to foreign keys in later migrations
t.string :comment_id  # Initially string
change_column :table, :comment_id, :bigint  # Changed later
```

### 2. Smart Index Detection
Recognizes indexes in multiple formats:

```ruby
# Single column indexes
add_index :users, :company_id

# Multi-column indexes
add_index :users, [:company_id, :department_id]

# Index defined in a separate migration
add_index :albums, :comment_id
```

### 3. Schema-Aware
- Uses `schema.rb` as the source of truth
- Catches foreign keys created across multiple migrations
- Detects when string/text columns are changed to foreign keys
- Validates against existing indexes

## Usage

1. Add this file to `.github/workflows/check_migration_indexes.yml`
2. The action automatically runs on PRs with migration changes
3. Enable debug mode by setting `DEBUG: "1"` in the workflow

## Error Messages

The action provides detailed error messages:

```
Error: Missing index for foreign key column 'comment_id' in table 'albums'
Details:
- Column type: bigint (64-bit integer typically used for foreign keys)
- Column appears to be a foreign key (ends with _id)
- Please add an index to improve query performance
- You can add it using: add_index :albums, :comment_id
```

## Common Scenarios

### ✅ Will Pass

```ruby
# Single migration with index
class AddCompanyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :bigint
    add_index :users, :company_id
  end
end

# References with index
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, index: true
      t.timestamps
    end
  end
end

# Multi-column index
class AddDepartmentToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :department_id, :bigint
    add_index :users, [:company_id, :department_id]
  end
end
```

### ❌ Will Fail

```ruby
# Missing index
class AddCompanyToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :company_id, :bigint
    # Missing index!
  end
end

# Foreign key created across migrations
class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string :comment_id  # Starts as string
    end
  end
end

class ChangeCommentIdType < ActiveRecord::Migration[7.0]
  def change
    change_column :albums, :comment_id, :bigint  # Changed to foreign key
    # Needs an index!
  end
end
```

## Debug Mode

Enable detailed logging by setting the DEBUG environment variable:

```yaml
- name: Check migrations for missing indexes
  env:
    DEBUG: "1"
  run: ...
```

Debug output includes:
- Detected foreign key columns
- Found indexes
- Schema parsing details
- Column type information

## Types of Foreign Keys Detected

1. **Bigint Columns** (`t.bigint`)
   - 64-bit integers typically used for foreign keys
   - Standard in modern Rails applications

2. **Integer Columns** (`t.integer`)
   - 32-bit integers commonly used for foreign keys
   - Legacy or smaller range foreign keys

3. **References** (`t.references`, `t.belongs_to`)
   - Rails association helpers
   - Automatically adds `_id` suffix

## Best Practices

1. Always add indexes when creating foreign key columns
2. Use `t.references` with `index: true` for cleaner migrations
3. Consider composite indexes for frequently combined queries
4. Add indexes in the same migration where foreign keys are created
5. Don't forget indexes when changing column types to foreign keys

## Limitations

1. Only detects columns ending in `_id`
2. Assumes standard Rails naming conventions
3. Requires `schema.rb` (not `structure.sql`)
4. Cannot detect custom foreign key naming patterns

## Contributing

Feel free to open issues or PRs for:
- Additional foreign key patterns
- New index detection methods
- Better error messages
- Performance improvements

## License

This project is available under the MIT License.
