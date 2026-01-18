# VO₂max Prediction Equations (Extracted from MATLAB Code)

## 1. Mechanical Load

The mechanical load in kg·m·min⁻¹ is:

```math
\text{load}_{kgm/min} = 1.33 \times (\text{step} \times \text{freq} \times \text{weight})
```

---

## 2. Astrand–Ryhming Model

### Age correction factor (smooth)

```math
cf(\text{age}) = 0.566 + \frac{12.825}{\text{age}}
```

### Maximum heart rate

```math
HR_{\max} = 220 - \text{age}
```

### Predicted VO₂max

```math
VO_{2,\text{Astrand}} = VO_{2,\text{sub}} \times \left(\frac{HR_{\max}}{HR}\right) \times cf(\text{age})
```

Where:

- `VO₂_sub = 19.8` mL·kg⁻¹·min⁻¹  
- `HR` is the measured heart rate in bpm

---

## 3. Milligan Equation

```math
VO_{2,\text{reg}} = 84.687 - 0.722 \left(\frac{HR}{2}\right) - 0.383 \times \text{age}
```

---

## 4. Sharkey Equation

### Maximum pulse

```math
\text{maxpulse} = 64.83 + 0.662 \times HR
```

### VO₂ in mL·kg⁻¹·min⁻¹

```math
VO_{2,\text{sharkey}} = \left(\frac{1}{2} \times 3.744 \times \frac{(\text{weight} + 5)}{(\text{maxpulse} - 62)}\right) \times \frac{1000}{\text{weight}}
```

---

## 5. Van Dobeln Equation

```math
VO_{2,\text{vandobeln}} = \left(1.29 \times \sqrt{\frac{\text{load}_{kgm/min}}{(\text{maxpulse} - 60)}} \times e^{-0.0088 \times \text{age}}\right) \times \frac{1000}{\text{weight}}
```
