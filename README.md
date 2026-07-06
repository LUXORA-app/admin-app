# LUXORA Administration Panel 

The LUXORA Admin Panel is the centralized web management interface designed to oversee, curate, and secure the LUXORA ecosystem. It provides system administrators with the tools necessary to manage user access, dynamically update historical monument registries, and maintain localization data.

This portal communicates directly with the central **Laravel REST API** hosted on secure Contabo cloud infrastructure.

---

##  Key Features

###  1. User Management Module
* **Access Control:** Monitor active platform users with full administrative oversight.
* **Account Restrictions:** Block or suspend users violating community guidelines or platform terms of service.
* **Account Deletion:** Safely and permanently remove user records and associated relational data in compliance with privacy guidelines.

### 2. Dynamic Explore Page & Landmark Curation
* **Add Landmarks:** Expand the LUXORA repository by creating new monument entries, complete with geographic map coordinates and metadata.
* **Update Content:** Edit titles, adjust coordinates, or update rich historical descriptions for existing landmarks instantly without requiring mobile app updates.
* **Remove Records:** Archive or permanently remove historical sites from the global discovery index.

###  3. Global Bilingual Support
* Fully localized administrative interface featuring fluid toggling between **Arabic** and **English** to support diverse operational teams.
* Dual-input forms allowing administrators to input monument data (descriptions, titles) in both languages simultaneously to feed the mobile localization pipeline.

---

## Tech Stack & Infrastructure

* **Backend Framework:** Laravel REST API [Backend link from mobile context]
* **Hosting Environment:** Contabo Cloud Infrastructure
* **Localization Standards:** Multi-locale routing (Arabic `ar` / English `en`)
* **System Diagnostics:** Stress-tested using Apache JMeter to ensure data-heavy administrative operations maintain high availability.

---

## 🏁 Getting Started

### Prerequisites

Ensure your server environment or local machine meets the following infrastructure requirements:
* **PHP:** v8.2 or higher
* **Composer:** Dependency Manager for PHP
* **Database:** MySQL 8.0+ or equivalent relational engine
* **Web Server:** Nginx or Apache configured with SSL

### Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone [https://github.com/your-organization/luxora-admin.git](https://github.com/your-organization/luxora-admin.git)
   cd luxora-admin
