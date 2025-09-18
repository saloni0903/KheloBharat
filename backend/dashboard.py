import streamlit as st
import pandas as pd
import os
import plotly.express as px

st.set_page_config(layout="wide")
st.title("SAI Sports Assessment Dashboard")

DB_FILE = "results_db.csv"

def load_data():
    if not os.path.exists(DB_FILE):
        return pd.DataFrame(columns=['athlete_id', 'test_type', 'jump_count', 'proof_clip_url'])
    return pd.read_csv(DB_FILE)

df = load_data()

st.header("Latest Jump Results")
if not df.empty:
    st.dataframe(df.tail(5).sort_index(ascending=False))
    
    st.header("All Test Results")
    st.data_editor(
        df,
        column_config={
            "proof_clip_url": st.column_config.LinkColumn("Video Proof"),
        },
        hide_index=True,
    )

    st.header("Analytics")
    avg_jump = df['jump_count'].mean()
    st.metric("Average Jump Count", f"{avg_jump:.2f}")

    if len(df) > 1:
        fig = px.line(df, x=df.index, y="jump_count", title="Jump Count Over Time")
        st.plotly_chart(fig)
else:
    st.write("No results to display yet.")