# Stitching Statistics

**A Tapestry of Urban and Rural Women's Disparities**
By Vrnda Aiyaswamy · Information Design Studio 2

An interactive data visualization that compares urban and rural conditions for women
across Indian states, rendered as a quilt. Each "patch" is a state; within it, twelve
segments encode key education and economic-empowerment metrics (literacy, 10+ years of
schooling, school attendance, paid cash work, house/land ownership, and bank-account
access) split by urban and rural areas. Hovering over any segment reveals a tooltip with
the state, variable, value, and its national rank.

The stitched line patterns act as the visual language: line density maps to each metric's
value, purple hues distinguish rural from urban, and slant direction distinguishes
education factors from economic-empowerment factors — weaving diverse urban and rural
narratives into a single national tapestry.

## Built with

- **Processing (Java)** — generative rendering and interaction
- **Playfair Display** — typography
- Source data: NFHS-5 (National Family Health Survey) urban/rural indicators, cleaned to CSV

## Interaction

- **Hover** over any segment of a state patch to see a tooltip with the exact value and
  that state's rank for the metric.
- Rankings are computed at load time across all states for each variable.

## Run it

1. Install [Processing](https://processing.org/download).
2. Open `final_layer_experimentation/final_layer_experimentation.pde`.
3. Press **Run** (▶). The sketch loads its data and fonts from the same folder
   (`Urban Rural Data Cleaned copy.csv`, `PlayfairDisplay-*.ttf`, `overlay.jpg`).

## Repository contents

- `final_layer_experimentation/` — the final interactive sketch and its assets
- `Final_layer/` — an earlier static version of the sketch
- `Code documentation.pdf` — the iterative design process (blobs → radial rings → line
  glyphs → grouped small multiples → final)
- `layer 1 ideation.pdf`, `Layer 1.jpg`, `LAYER 2 STATIC VIZ (1).png`, `STATES FINAL.png`
  — process and layer artifacts
