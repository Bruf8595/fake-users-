# SQL-only Fake User Generator 

## Stored Procedures Documentation


| `rnd(seed BIGINT, idx INT)` | Deterministic pseudo-random [0,1) | Safe LCG with modulus 2³¹-1 |
| `normal(mean, stddev, seed, idx)` | Normal distribution | Box-Muller transform |
| `geo_uniform(seed, idx)` | Uniform point on Earth sphere | lat = asin(2×u−1)×180/π, lon = v×360−180 |
| `pick_from(...)` | Deterministic lookup from locale-aware tables | OFFSET floor(rnd×count) % count |
| `pick_eye_color(idx)` | Weighted eye color | Brown 45%, Blue 27%, Green 15%, Hazel 8%, Gray 5% |
| `generate_full_name(...)` | Full name with title/middle variations | ~30% title, ~40% middle name |
| `generate_address(...)` | Locale-aware address | Random street, city, zip, 50% apt |
| `generate_phone(...)` | Locale-specific phone format | Pattern substitution |
| `generate_email(...)` | Realistic email | first[.last]@domain |
| `generate_batch(...)` | Main function — returns 10 users as JSON | Loops and combines all above |

## Performance
~2200–2800 users/second on local machine (10 000 users ≈ 4 sec)

## How to run
```bash
pip install -r requirements.txt
python app.py
```
Open http://127.0.0.1:5000