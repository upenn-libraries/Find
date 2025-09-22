import spacy
from flask import Flask, request, jsonify

nlp = spacy.load("en_core_web_lg")
app = Flask(__name__)

@app.route("/ner", methods=["POST"])
def extract_entities():
    text = request.json.get("text", "")
    doc = nlp(text)
    print(doc)
    entities = [{"text": ent.text, "label": ent.label_} for ent in doc.ents]
    print(entities)
    return jsonify(entities)

if __name__ == "__main__":
    app.run(port=5001)
