# PL/pgSQL Coding Showcase

This code shows my **PL/pgSQL coding style** and highlights some of my key skills in database design, procedural logic, and advanced querying.


---

## 1. Database Design & DDL Skills

### Normalization:
A practical, real-world HR/payroll system implementation including:
- `emp`, `dept`, `job`, `career`, `salary` tables.

### Constraints & Validation:
- `CHECK` constraints for valid date ranges and salary thresholds.
- `FOREIGN KEY`s for referential integrity across related tables.

### Types & Extensions:
- Custom `ENUM` type: `job_category`.
- `hstore` extension to store semi-structured key-value metadata.
- `JSONB` and `ARRAY` usage for handling flexible employee details.

---

## 2. Functions & Triggers (PL/pgSQL)

### Triggers:
- `empname_format_trigger`: Automatically capitalizes employee names.
- `trg_check_salary_threshold`: Ensures salary updates meet job minimums.

### Custom Logic:
- `check_salary_min_threshold`: Enforces salary business rules.
- `calculate_salary_tax`: Computes dynamic, progressive tax based on salary thresholds.
- `update_emp_phone`: Cleans phone numbers using regex formatting.

---

## 3. Queries & Data Manipulation

### Advanced SELECTs:
- Extracts keys/values from `JSONB` (`extra_info`).
- Uses `unnest()` to expand `skills` array.
- Employs `SUM(...) OVER (...)` window function for cumulative salary analysis.

### Data Loading:
- Realistic insertions simulating diverse employee data with detailed metadata.

---

## 4. Views

### Materialized View: `mv_emp_details`
- Consolidates employee data across multiple tables.
- Enriches output with manager names and salary history.
- Ends with a `REFRESH MATERIALIZED VIEW` for up-to-date reporting.

---

