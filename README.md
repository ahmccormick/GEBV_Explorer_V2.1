# GEBV Explorer v2.1

Interactive visualization of genomic estimated breeding values (GEBVs) for Capsicum (pepper) crops. A single unified app covering both the core and global collections, with AI-assisted filtering and multi-trait selection indices.



## Features

- **Collection Toggle**: Switch between the Core Collection (n=397) and Global Collection (n=7,843) from the sidebar
- **Interactive Sliders**: Filter lines by any GEBV trait using sidebar threshold sliders
- **Chat with Data Filtering**: Use natural language to adjust filters or rank lines (e.g., "Show me the top 10% for yield", "Rank lines prioritising yield and Brix")
- **Genomic Selection Index**: Accuracy-adjusted ranking using `b = (RGR)⁻¹RGa` — accounts for covariance among predicted GEBVs and unequal prediction accuracies
- **Weighted Selection Index**: Simple z-score weighted ranking `I = Σ(wⱼ × zᵢⱼ)` — straightforward weighted composite score
- **Scatter Plot**: Explore any two-trait scatterplot with filtered points highlighted
- **CSV Export**: Download filtered lines or index results as CSV

---

## Running with Docker

Docker bundles everything — no Python setup, no virtual environments, no dependency conflicts.

### Requirements
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac/Windows) or Docker Engine (Linux)
- An Anthropic API key from https://console.anthropic.com/

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/ahmccormick/GEBV_Explorer_V2.1.git
cd GEBV_Explorer_V2.1
```

**2. Start the app**
```bash
docker compose up --build
```

The app will be available at **http://localhost:8501**

To stop: press `Ctrl+C`, then `docker compose down`.

**Providing your API key:**

Enter your Anthropic API key directly in the app sidebar — no `.env` file needed. Alternatively, create a `.env` file to pre-fill it automatically:
```bash
echo "ANTHROPIC_API_KEY=your-api-key-here" > .env
```

> **Note:** The first `docker compose up` will take a few minutes to build the image and download dependencies. Subsequent starts are fast.

---

## Running Manually (Without Docker)

### 1. Clone the repository
```bash
git clone https://github.com/ahmccormick/GEBV_Explorer_V2.1.git
cd GEBV_Explorer_V2.1
```

### 2. Create and activate a virtual environment (Python 3.12)
```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```
On Windows, activate with `.venv\Scripts\activate` and use Git Bash for the startup script, or start the Python services separately.

### 3. Start the app
```bash
bash start_core.sh
```
This starts the core API, global API and Streamlit interface. Open **http://localhost:8501**.
Enter an Anthropic API key in the app sidebar to enable chat. Manual filtering and index calculations do not require an API key.

For subsequent sessions, activate `.venv` before starting. If you move the folder, recreate the virtual environment at the new location.

The current startup script can leave background API processes running after Streamlit stops. If ports 5001 or 5002 are occupied on macOS, inspect them with `lsof -nP -iTCP:5001 -iTCP:5002 -sTCP:LISTEN` and stop only the identified app processes before restarting.

---

## Usage

### Switching Collections
Use the **Collection** radio button in the sidebar to toggle between:
- **Core Collection (n=397)** — Capsicum core collection, 96 GEBV traits
- **Global Collection (n=7,843)** — Global Capsicum collection, 96 GEBV traits

### Manual Filtering
- Adjust sliders on the left sidebar to filter lines by any GEBV trait
- The scatter plot and filtered table update in real time
- Red points in the scatter plot highlight lines meeting all threshold criteria

### Chat with Data Filtering
Use natural language commands to adjust filters or rank lines:
- *"Show me the top 10% for yield"*
- *"Filter for high Brix and low pungency"*
- *"Rank lines prioritising yield twice as much as Brix"*
- *"Reset all filters"*

### Genomic Selection Index
Ranks all lines using an accuracy-adjusted genomic index `b = (RGR)⁻¹RGa`:
- Select traits and assign economic weights
- The index accounts for covariance among predicted GEBVs and prediction accuracies
- Results show derived coefficients alongside your input weights so you can see how the adjustment affected the ranking

### Weighted Selection Index
Ranks all lines using a simple z-score weighted composite score `I = Σ(wⱼ × zᵢⱼ)`:
- Select traits and assign weights
- Traits are standardised before combining so they are on the same scale
- A straightforward approach when you want a transparent weighted ranking

---

## Data

All data files are in the `data/` directory.

| File | Description |
|---|---|
| `GEBVs_quality_23trait_n397.csv` | Core collection quality traits (23 traits, n=397) |
| `GEBVs_STI_73traits_BLUEadjusted_ALL_n397.csv` | Core collection agronomic traits (73 traits, n=397) |
| `n397_PAs_96traits.csv` | Trait prediction accuracies for core collection |
| `GEBVs_quality_23trait_n7843.csv` | Global collection quality traits (23 traits, n=7,843) |
| `GEBVs_STI_73traits_BLUEadjusted_ALL_n7843.csv` | Global collection agronomic traits (73 traits, n=7,843) |
| `n7843_PAs_96traits.csv` | Trait prediction accuracies for global collection |
| `Trait_Metadata_with_Synonyms.xlsx` | Trait descriptions, units, and synonyms used by the chat assistant |

The app retains all 96 trait entries; it does not automatically exclude traits with PA at or below 0.5. The PA tables are used by the accuracy-adjusted index. Agronomic entries represent STI-derived predictions, while quality predictions were generated separately. Trait identifiers are distinct between the two tables, so the revised merged dataset does not require `_x`/`_y` suffixes.

---

## Architecture

```
GEBV_app.py              # Unified Streamlit app (Core + Global, both indices)
gebv_api_server.py       # Flask API — core collection (port 5001)
gebv_mcp_server.py       # MCP server — core collection tools
mcp_chat.py              # Chat integration — core collection

global/
├── global_api_server.py     # Flask API — global collection (port 5002)
├── global_mcp_server.py     # MCP server — global collection tools
└── global_mcp_chat.py       # Chat integration — global collection

data/                        # All data files (core + global)

Dockerfile                   # Single image
docker-compose.yml           # Single service, starts both API servers + app
start_core.sh                # Startup script (used by Docker)
```

Both API servers must be running for the collection toggle to work. The Docker setup starts them both automatically via `start_core.sh`.

## LLM model and evaluation

The core and global chat modules use Claude Sonnet 5.5 (`claude-sonnet-5-5`). A structured prompt supplies trait metadata, synonyms, percentile rules and MCP tool descriptions. The model invokes local MCP tools, which communicate with the corresponding Flask API. The model does not fit genomic prediction models.

A small reference-based evaluation checked percentile filters, combined trait criteria, synonym interpretation and weighted rankings against independently computed accession sets. These checks assess execution of the tested queries, not biological validity of the predictions or comprehensive robustness across all requests.

This repository contains the application source and data. The GitHub repository URL is not a hosted running application; use the local or Docker setup above.
