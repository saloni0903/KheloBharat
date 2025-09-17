import streamlit as st
import pandas as pd
import os

st.set_page_config(layout="wide")
st.title("SAI Sports Assessment Dashboard")

DB_FILE = "results_db.csv"

def load_data():
    if not os.path.exists(DB_FILE):
        return pd.DataFrame(columns=['athlete_id', 'test_type', 'jump_count', 'proof_clip_url'])
    return pd.read_csv(DB_FILE)

df = load_data()

st.subheader("Latest Jump Results")
st.dataframe(df)

if not df.empty:
    st.subheader("Results with Video Proof")
    df_with_proof = df.copy()
    st.data_editor(
        df_with_proof,
        column_config={
            "proof_clip_url": st.column_config.LinkColumn("Video Proof"),
        },
        hide_index=True,
    )
else:
    st.write("No results to display.")