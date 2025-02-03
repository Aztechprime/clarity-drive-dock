# DriveDock
A decentralized carpooling platform built on Stacks blockchain that connects drivers and riders within neighborhoods.

## Features
- Create and manage ride listings
- Book available rides
- Rate drivers and riders
- Neighborhood-based ride matching
- Secure payments via STX

## Smart Contracts
The project contains the following contracts:
- `drive-dock.clar`: Main contract handling ride listings and bookings
- `user-registry.clar`: Manages user profiles and ratings
- `payment-handler.clar`: Handles payment escrow and transfers

## Testing
Run tests using Clarinet:
```bash
clarinet test
```
