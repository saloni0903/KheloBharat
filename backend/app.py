from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
import uvicorn
import os
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allows all origins for mobile app testing
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class JumpResult(BaseModel):
    athlete_id: str
    test_type: str
    jump_count: int
    proof_clip_url: str

DB_FILE = "results_db.csv"
if not os.path.exists(DB_FILE):
    df = pd.DataFrame(columns=['athlete_id', 'test_type', 'jump_count', 'proof_clip_url'])
    df.to_csv(DB_FILE, index=False)

@app.post("/submit_result")
def submit_result(result: JumpResult):
    try:
        df = pd.read_csv(DB_FILE)
        new_row = pd.DataFrame([result.dict()])
        df = pd.concat([df, new_row], ignore_index=True)
        df.to_csv(DB_FILE, index=False)
        return {"status": "success", "message": "Result submitted."}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)