# Lanka Express — Bus Ticket Booking System

A web-based bus ticket reservation and seat inventory management system designed around structured booking workflows, real-time seat availability tracking, and relational database integrity.

## Live Demo
- **Hosted Web Application:** [https://lankaexpress.netlify.app](https://lankaexpress.netlify.app)

## Overview & Business Workflow
Lanka Express models core operational and order-to-cash workflows—route and schedule lookup, real-time seat inventory allocation, reservation processing, and passenger booking records—backed by a normalized relational database.

### Key Capabilities
- **Route & Schedule Management:** Structured lookup of bus routes, departure schedules, and fare details.
- **Seat Inventory Control:** Real-time tracking of available and reserved seats to prevent double-booking conflicts during peak demand.
- **Booking & Transaction Integrity:** Relational schema enforcing primary/foreign key constraints across buses, routes, schedules, passengers, and bookings.
- **Role-Based Operations:** Supports passenger ticket reservation flows alongside staff/administrative schedule and booking oversight.

## Database Architecture (SQL)
This repository contains the relational database scripts used to structure and populate the system:

- **`Table Creation.sql`** — Defines the database schema, tables, primary/foreign keys, data types, and relational constraints.
- **`Data Enter.sql`** — Populates initial master and transactional records (routes, bus schedules, seat configurations, and sample entries).

### Setup & Execution Order
1. Open your SQL environment (e.g., **Microsoft SQL Server Management Studio (SSMS)**).
2. Create a new target database (e.g., `LankaExpressDB`).
3. Execute **`Table Creation.sql`** first to generate all tables and relationships.
4. Execute **`Data Enter.sql`** second to insert the sample/initial dataset.

## Tech Stack
- **Database:** Microsoft SQL Server (T-SQL)
- **Backend / API:** Node.js, Express, REST APIs
- **Frontend:** HTML5, CSS3, JavaScript
- **Hosting & Deployment:** Netlify

## Project Ownership & Collaboration
- **Database Architecture, System Workflow & Backend Logic:** Yomal Kahawala ([GitHub](https://github.com/YomalD2004) | [LinkedIn](https://www.linkedin.com/in/yomal-kahawala))
- **Frontend Deployment:** Hosted on Netlify in collaboration with project team.
