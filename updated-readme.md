# shaun-stack (Final Version)

This is an updated version of the week 5 README.md, relevant to the Week 7 React dashboard (fleet-console) that was implemented with respect to the Week 6 telemetry bridge (aido-bridge) and the Week 4 anomaly event detector (sentinel-events). This is just meant to be a brief walkthrough of how to run the dashboard and all the related services, as all the aspects of the dashboard have been covered in each week's respective READMEs and weekly recaps.

## How to run it

(Do note that you must have Git, Node.js 20 LTS, and Docker installed on your system before you can run these commands)

1. Clone all the required repos as siblings in the directory that you plan to run the dashboard from.

```bash
git clone https://github.com/ShaunTheSheep25/shaun-stack.git
git clone https://github.com/ShaunTheSheep25/fleet-console.git
git clone https://github.com/ShaunTheSheep25/sentinel-events.git
git clone https://github.com/ShaunTheSheep25/aido-bridge.git
git clone https://github.com/ShaunTheSheep25/aido-telemetry.git
```

2. Enter into shaun-stack and run all the services simultaneously with `make up`.

```bash
git clone https://github.com/ShaunTheSheep25/shaun-stack.git
cd shaun-stack
make up
```

Then, open `http://localhost:3000` in your browser to view the dashboard.