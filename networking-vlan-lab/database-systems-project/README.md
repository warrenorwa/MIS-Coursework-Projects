# Database Systems: Wellmeadows Hospital Project

The Wellmeadows Hospital scenario implemented independently across three database
systems, for MIS6050 (Database Systems). Covers schema design, stored procedures,
triggers, object types, and aggregation pipelines — with a written comparison of the
three approaches.

## Structure

- **`mysql/`** — Schema, stored procedures, and triggers implemented in MySQL
  (via XAMPP/phpMyAdmin)
- **`oracle/`** — Schema (DDL), PL/SQL stored procedures, triggers, and object types
  implemented in Oracle XE (via SQL Developer)
- **`mongodb/`** — Collection design and aggregation pipelines implemented in MongoDB
  (Atlas/Compass)
- **`docs/`** — Comparative report evaluating relational vs. document-store design
  trade-offs across all three systems (APA/STE100 style)

## What's demonstrated

- Full ER-to-schema design for a real-world hospital management scenario
- Stored procedures and triggers for business logic enforcement (MySQL, Oracle)
- PL/SQL object types (Oracle)
- Document modeling and aggregation pipelines (MongoDB)
- A structured comparison of relational and document-store approaches to the same
  data problem

## How to run

- **MySQL:** import the `.sql` file via phpMyAdmin or `mysql < schema.sql`
- **Oracle:** run scripts in SQL Developer against an Oracle XE instance
- **MongoDB:** run the `.js` scripts via `mongosh` or import collections into Compass/Atlas
