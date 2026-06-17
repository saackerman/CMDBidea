# Enterprise Static CMDB - User Guide

## Overview

The **Enterprise Static CMDB** (Configuration Management Database) is a lightweight, browser-based application for searching and discovering your organization's infrastructure assets, services, and dependencies. It provides instant, real-time search filtering across 4,000+ enterprise services including cloud platforms, security tools, databases, container orchestration, networking, and more.

## Features

- **4,000+ Pre-Populated Services** – Comprehensive coverage of modern enterprise infrastructure
- **Real-Time Search** – Filter results instantly as you type
- **Multi-Term Search** – Combine multiple search terms for precise filtering
- **Dark Mode Support** – Automatic dark/light mode based on system preferences
- **Responsive Design** – Works on desktop, tablet, and mobile devices
- **Metadata Badges** – Quick visual indicators for environment, tier, and status
- **No Installation Required** – Single HTML file, works in any modern browser

## Getting Started

### Opening the Application

1. **Open in Browser**
   - Double-click `gemini-code-1781713361573.html` to open in your default browser, or
   - Right-click → "Open with" and select your preferred browser (Chrome, Firefox, Safari, Edge)

2. **Live Preview (VS Code)**
   - Open the file in VS Code
   - Click the "Go Live" button in the bottom-right corner (requires Live Server extension), or
   - Right-click the file and select "Open with Live Server"

### First Look

When you open the application, you'll see:
- **Header** – "Internal Infrastructure Asset CMDB"
- **Search Bar** – Text input field at the top
- **Asset Grid** – Card-based layout displaying all services (initially showing all 4,000 entries)
- **Dark Mode Toggle** – Automatic based on your system theme

---

## How to Search

### Single-Term Search

Type a service name or keyword to filter results instantly.

**Examples:**
- `kubernetes` – Shows all Kubernetes-related services
- `production` – Shows all production environment services
- `critical` – Shows all critical-tier services
- `10.240` – Shows all services with IP addresses in the 10.240.x.x range

### Multi-Term Search

Combine multiple search terms with spaces to narrow results. **All terms must match** for an asset to be included.

**Examples:**
- `production critical` – Shows production services with critical tier
- `kubernetes staging` – Shows Kubernetes services in staging environment
- `security operations` – Shows services from the Security Operations team
- `db production 10.240` – Shows production database services on the 10.240 network

### Case-Insensitive

Searches work regardless of capitalization.
- `PROMETHEUS`, `prometheus`, `Prometheus` all return the same results

### Search Scope

The search filters across all asset properties:
- **Service Name** – The human-readable name
- **Service ID** – Unique identifier (e.g., `svc-kubernetes-0`)
- **Support Group** – The team responsible
- **Environment** – production, staging, testing, development
- **Tier** – critical, high, medium, low
- **IP Address** – Network address range

---

## Understanding Service Cards

Each service is displayed as a card with the following information:

```
╔════════════════════════════════════════╗
║ Service Name                      [ID] ║
║                                        ║
║ Support Group: Security Operations     ║
║ Environment: [production] Tier: [crit] ║
║ IP: 10.240.20.1                        ║
║ Wiki: https://wiki.company.com/...     ║
║ Management: https://admin.company.com/... ║
╚════════════════════════════════════════╝
```

### Field Descriptions

| Field | Meaning | Example |
|-------|---------|---------|
| **Service Name** | Human-readable service identifier | `CrowdStrike Falcon Agent` |
| **Service ID** | Unique machine-readable identifier | `svc-crowdstrike-falcon-0` |
| **Support Group** | Team responsible for this service | `Security Operations` |
| **Environment** | Deployment environment | `production`, `staging`, `testing`, `development` |
| **Tier** | Service criticality level | `critical`, `high`, `medium`, `low` |
| **IP Address** | Network address or address range | `10.240.20.1` or `52.94.12.45` |
| **Wiki URL** | Link to service documentation | `https://wiki.company.com/x/CS001` |
| **Management URL** | Link to the service management console or admin page | `https://admin.company.com/services/payment-gateway` |

---

## Service Categories

The CMDB includes services across these major categories:

### Identity & Access (IAM)
- Active Directory, Azure AD, Okta SSO/MFA, GitHub, GitLab

### Cloud Infrastructure
- AWS (EC2, RDS, S3), Azure (Compute, Storage, SQL), GCP (Compute, Storage)

### Security & Threat Detection
- CrowdStrike, Huntress, Qualys, Nessus, vulnerability scanners

### Monitoring & Observability
- Datadog, Prometheus, Grafana, Splunk, New Relic, Elastic Stack

### Databases
- PostgreSQL (primary/replica), MongoDB, MySQL, Redis, Cassandra, HBase

### Container & Orchestration
- Kubernetes (API, etcd, nodes), Docker, Docker Swarm, Compose

### Messaging & Collaboration
- Kafka, RabbitMQ, Slack, Microsoft Teams, Zoom

### Storage & Backup
- NetApp, EMC VMAX, Pure Storage, NFS, SMB, Commvault, Veeam

### Networking
- Nginx, HAProxy, Palo Alto, Fortinet, DNS, Firewalls, Load Balancers

### Virtualization
- VMware (vCenter, ESXi), Hyper-V, Citrix XenServer, KVM

### Infrastructure as Code
- Terraform, Ansible, Puppet, Chef

### CI/CD
- Jenkins, GitLab CI, GitHub Actions, CircleCI

---

## Common Use Cases

### 1. Find All Critical Production Services

**Search:** `production critical`

Returns all services that are both in production and marked as critical tier. Useful for identifying your highest-impact infrastructure.

### 2. Identify Services by Support Team

**Search:** `platform engineering`

Returns all services owned by the Platform Engineering team. Useful for cross-team dependency mapping.

### 3. Locate Services on a Network Subnet

**Search:** `10.240` or `203.45.123`

Returns all services hosted on a specific network range. Useful for network troubleshooting and capacity planning.

### 4. Find Test Environment Services

**Search:** `testing`

Returns all services deployed in the testing environment. Useful for pre-production validation.

### 5. Search for Specific Technology

**Search:** `kubernetes production`

Returns all Kubernetes services in production. Useful for understanding container orchestration footprint.

### 6. Find Services by IP Address

**Search:** `10.240.20.1`

Returns the specific service at that IP. Useful for network troubleshooting when you have an IP but need service context.

---

## Tips & Tricks

### ✓ **Combine Terms for Precision**
- More specific results = fewer terms combined with broad keywords
- `kubernetes` = 50+ results
- `kubernetes production` = 25+ results
- `kubernetes production critical` = 5-10 results

### ✓ **Use Partial Matches**
- Search for partial service names: `aws` finds AWS EC2, AWS RDS, AWS S3, etc.
- Search for partial team names: `security` finds Security Operations, Security Engineering, etc.

### ✓ **Search by Network Prefix**
- `10.240` – Internal network services
- `52.94` – AWS services
- `203.45.123` – External services

### ✓ **Clear Search to Reset**
- Delete all search text to see the full 4,000-entry catalog again

### ✓ **Bookmark Important Searches**
- Save browser bookmarks with search terms in the URL to quickly return to filtered views
- Example: Save `CMDB - Production Critical` as a quick filter link

### ✓ **Dark Mode**
- Automatically follows your system theme (Settings → Display)
- Toggle by changing your OS light/dark preference

---

## Data Structure

Each service entry contains:

```json
{
  "id": "svc-crowdstrike-falcon-0",
  "name": "CrowdStrike Falcon Agent",
  "support_group": "Security Operations",
  "confluence_url": "https://wiki.company.com/x/CS001",
  "environment": "production",
  "tier": "critical",
  "ip": "10.240.20.1"
}
```

All 4,000 entries follow this consistent structure, embedded directly in the HTML file.

---

## Browser Compatibility

The CMDB works with all modern browsers:
- ✓ Chrome/Chromium (v90+)
- ✓ Firefox (v88+)
- ✓ Safari (v14+)
- ✓ Microsoft Edge (v90+)

### Requirements
- No plugins or extensions required
- JavaScript must be enabled
- ~1 MB free memory
- Internet connection not required (fully offline-capable)

---

## File Information

| Property | Value |
|----------|-------|
| File Name | `gemini-code-1781713361573.html` |
| File Size | ~770 KB |
| Total Entries | 4,000 services |
| Format | Single-file HTML5 application |
| Dependencies | None (pure HTML/CSS/JavaScript) |
| License | Internal use only |

---

## Troubleshooting

### **Search not working**
- Ensure JavaScript is enabled in your browser
- Try refreshing the page (Ctrl+R or Cmd+R)
- Clear browser cache and reload

### **Page loads slowly**
- This is normal with 4,000 entries on older systems
- Search filters faster as you type, narrowing down results
- Try using more specific search terms

### **Can't find a service**
- Try searching for partial names or keywords
- Verify the team name or IP range you're searching for
- Check if the service exists in the catalog (4,000 is comprehensive but may not include all custom internal services)

### **Dark mode not working**
- Check your OS dark mode setting (Windows Settings → Display or Mac System Preferences → Appearance)
- The CMDB will automatically match your system theme

---

## Extending the CMDB

### Adding New Services

To add more services or update existing ones:

1. Open the HTML file in a text editor
2. Locate the `const assets = [...]` array (around line 223)
3. Add or modify service entries following the standard JSON format
4. Save the file and refresh your browser

### Example New Entry

```javascript
{
  "id": "svc-new-service-0",
  "name": "My New Service",
  "support_group": "My Team",
  "confluence_url": "https://wiki.company.com/x/MYNEW",
  "management_url": "https://admin.company.com/services/my-new-service",
  "environment": "production",
  "tier": "high",
  "ip": "10.240.100.1"
}
```

---

## Support & Questions

For questions or issues with the CMDB:

1. **Check the FAQ above** – Most common issues are covered
2. **Review the data** – Click through services to understand the structure
3. **Test search combinations** – Experiment with multi-term searches
4. **Consult team documentation** – Each service has a Confluence link for detailed info

---

**Last Updated:** 2026-06-17  
**Version:** 1.0  
**Enterprise Infrastructure Asset CMDB**
