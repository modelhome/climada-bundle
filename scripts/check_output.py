"""Check a model output file against the Modelfile's output schema.

Usage: python scripts/check_output.py Modelfile-fanout.toml output.json
"""

import json
import sys
import tomllib

import jsonschema


def main(modelfile_path: str, output_path: str) -> None:
    with open(modelfile_path, "rb") as f:
        modelfile = tomllib.load(f)
    schema = modelfile["outputs"][0]["schema"]
    with open(output_path) as f:
        output = json.load(f)
    jsonschema.validate(output, schema)
    print(f"output matches the {modelfile['outputs'][0]['name']} schema")
    print(f"aai_agg_usd={output['aai_agg_usd']:.0f} events={len(output['event_loss_table'])}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
