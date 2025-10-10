# ⚡ Community Microgrid Energy Trading

> Empowering neighborhoods to trade solar power locally through blockchain technology

## 🌟 Overview

A decentralized energy marketplace built on Stacks blockchain that enables neighborhoods to trade solar power directly. Producers list their excess solar energy, consumers purchase what they need, and Clarity smart contracts automatically manage pricing, distribution, and payments.

## ✨ Features

- 🔌 **Producer Registration**: Solar panel owners can register and track their energy production
- 🏘️ **Consumer Registration**: Community members can register to purchase local energy
- 📊 **Energy Tracking**: Real-time tracking of production, sales, and consumption
- 💰 **Marketplace Listings**: Producers set their own price-per-unit for energy sales
- 🤝 **Automated Trading**: Smart contract handles all transactions and settlements in STX
- 📈 **Transaction History**: Complete audit trail of all energy trades
- ❌ **Listing Management**: Producers can cancel unfilled listings

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet with STX for transactions

### Installation

```bash
git clone https://github.com/haruna-bit/Community-Microgrid-Energy-Trading.git
cd Community-Microgrid-Energy-Trading
clarinet check
```

## 📖 Usage Guide

### For Energy Producers 🌞

**1. Register as a Producer**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading register-producer)
```

**2. Add Energy Production**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading add-energy-production u1000)
```

**3. Create a Listing**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading create-listing u500 u10)
```
- Energy amount: 500 units
- Price per unit: 10 microSTX

**4. Cancel a Listing (if needed)**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading cancel-listing u0)
```

### For Energy Consumers 🏠

**1. Register as a Consumer**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading register-consumer)
```

**2. Purchase Energy from a Listing**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading buy-energy u0)
```
- Listing ID: 0
- Payment in STX is automatically transferred to the producer

### Read-Only Functions 📊

**Check Producer Details**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading get-producer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**Check Consumer Details**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading get-consumer 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

**View Listing Information**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading get-listing u0)
```

**View Transaction Details**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading get-transaction u0)
```

**Get Total Energy Traded**
```clarity
(contract-call? .Community-Microgrid-Energy-Trading get-total-energy-traded)
```

## 🔧 Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `register-producer` | Register as an energy producer | None |
| `register-consumer` | Register as an energy consumer | None |
| `add-energy-production` | Add produced energy to balance | `amount: uint` |
| `create-listing` | List energy for sale | `energy-amount: uint, price-per-unit: uint` |
| `buy-energy` | Purchase energy from listing | `listing-id: uint` |
| `cancel-listing` | Cancel an unfilled listing | `listing-id: uint` |
| `deactivate-producer` | Deactivate producer account | None |
| `deactivate-consumer` | Deactivate consumer account | None |

### Read-Only Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `get-producer` | Get producer information | `producer: principal` |
| `get-consumer` | Get consumer information | `consumer: principal` |
| `get-listing` | Get listing details | `listing-id: uint` |
| `get-transaction` | Get transaction details | `transaction-id: uint` |
| `get-total-energy-traded` | Get total energy traded on platform | None |
| `get-listing-count` | Get total number of listings | None |
| `get-transaction-count` | Get total number of transactions | None |

## 🎯 Use Cases

1. **Residential Solar Trading**: Homeowners with solar panels sell excess energy to neighbors
2. **Community Energy Pools**: Neighborhoods collaborate to optimize energy distribution
3. **Peak Hour Trading**: Producers capitalize on high-demand periods with dynamic pricing
4. **Green Energy Credits**: Track and verify renewable energy consumption
5. **Microgrid Management**: Coordinate energy flow within apartment complexes or communities

## 🔐 Security Features

- Principal-based authentication for all transactions
- Duplicate registration prevention
- Balance verification before listing creation
- Double-spend protection on listings
- Automated payment settlement through STX transfers
- Active status checks for participants

## 📝 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | `err-owner-only` | Action restricted to contract owner |
| u101 | `err-not-registered` | User not registered |
| u102 | `err-already-registered` | User already registered |
| u103 | `err-invalid-amount` | Invalid energy amount |
| u104 | `err-invalid-price` | Invalid price |
| u105 | `err-insufficient-energy` | Insufficient energy balance |
| u106 | `err-listing-not-found` | Listing does not exist |
| u107 | `err-unauthorized` | Unauthorized action |
| u108 | `err-payment-failed` | STX payment failed |
| u109 | `err-already-filled` | Listing already filled |

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

Check contract syntax:
```bash
clarinet check
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License

## 🌐 Links

- **Repository**: [GitHub](https://github.com/haruna-bit/Community-Microgrid-Energy-Trading)
- **Stacks Documentation**: [Clarity Language](https://docs.stacks.co/clarity)
- **Clarinet**: [Documentation](https://github.com/hirosystems/clarinet)

---

Built with ❤️ for sustainable energy communities
