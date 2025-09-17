from fastapi import FastAPI
from pydantic import BaseModel
import pandas as pd
import uvicorn
import os

app = FastAPI()

class JumpResult(BaseModel):
    athlete_id: str
    test_type: str
    jump_count: int
    proof_clip_url: str # New field

DB_FILE = "results_db.csv"
if not os.path.exists(DB_FILE):
    df = pd.DataFrame(columns=['athlete_id', 'test_type', 'jump_count', 'proof_clip_url'])
    df.to_csv(DB_FILE, index=False)

@app.post("/submit_result")
def submit_result(result: JumpResult):
    try:
        df = pd.read_csv(DB_FILE)
        new_row = pd.DataFrame([{
            "athlete_id": result.athlete_id,
            "test_type": result.test_type,
            "jump_count": result.jump_count,
            "proof_clip_url": result.proof_clip_url
        }])
        df = pd.concat([df, new_row], ignore_index=True)
        df.to_csv(DB_FILE, index=False)
        return {"status": "success", "message": "Jump count submitted."}
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)