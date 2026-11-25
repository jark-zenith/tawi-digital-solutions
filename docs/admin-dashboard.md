# Admin dashboard: design proposal

This document describes the proposed admin dashboard for the Tawi Digital Solutions website. It is a design proposal, not a deployed system. The screen designs are in [`design/admin-dashboard/`](../design/admin-dashboard/).

## Principles

- Every founder signs in with their own account and has full access to the dashboard.
- Everything is editable. Services, statuses, roles and company details are data the team updates, not fixed text.
- Private founder information and customer contact details are never shown on public pages.
- No secrets, customer records or founder contact details are committed to this repository.

## Screens

| Screen | Purpose |
| --- | --- |
| Dashboard | Overview: founder count, approved profiles, services, customers, new inquiries, to-do list and latest inquiries. |
| Inbox | Customer inquiries from the website. Filter by status, open WhatsApp, set status, assign a founder, add follow-up notes. |
| Founders | Invite founders by email, see each founder's status, review submitted profiles and tick which fields may appear on the public team page. |
| Services | The list of services. Add, rename, describe, change status (Idea, Demo, Pilot, Live, Paused) or remove. A "Show on website" switch controls which services appear on the public site. |
| Customers | Pipeline of businesses by stage: Lead, Contacted, Pilot, Customer, with a details form. |
| Settings | Company details, who can sign in, and a record of agreed roles and ownership. |

## Inquiry flow

1. A visitor opens the public website and chooses a service.
2. They enter a WhatsApp number (required) and optionally an email and a short message, then send.
3. The inquiry is saved to the database and appears in the Inbox for every founder.
4. Founders follow up on WhatsApp and decide who takes the service by assigning it.
5. Status and notes are updated as the follow-up progresses.

### Proposed inquiry record

| Field | Notes |
| --- | --- |
| `id` | Unique identifier |
| `name` | Customer name (optional on the form) |
| `whatsapp` | Required |
| `email` | Optional |
| `service` | The service chosen on the website |
| `message` | Optional text from the customer |
| `status` | `New`, `Contacted`, `In progress`, `Closed` |
| `assigned_to` | The founder who takes the service, or unassigned |
| `notes` | Internal follow-up notes |
| `created_at` | Timestamp |

## Founder profile fields

Submitted by each founder and reviewed in the Founders screen.

- Possible public fields: display name, photo, role or title, short bio, skills.
- Private fields: phone, email, location, experience, availability.

Only fields an approver marks as public may reach the public team page. Do not collect identity documents or ID numbers.

## Open decisions

- Technology stack and hosting. Not chosen yet.
- Sign-in method and whether any action should be limited beyond "full access for every founder".
- Final role assignments and the ownership arrangement, which the README says still need to be agreed.
- How WhatsApp follow-up is done: manually through a chat link, or through an integration.

## Status

All numbers, names and phone numbers in the designs are placeholders.
