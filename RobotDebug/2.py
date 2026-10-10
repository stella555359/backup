import json

# Example bwp parameter
bwp = [
    {
        "dist_name": "MRBTS-80/NRBTS-80/NRCELL-302",
        "parameter": "cellBwpList",
        "value": [
            {
                "actPdcchCceFragmentControl": False,
                "actUpperThrAckNackFiltering": True,
                "actUpperThrAckNackHrFiltering": True,
                "bwpDN": "MRBTS-80/NRBTS-80/BWP_PROFILE-11001"
            },
            {
                "actPdcchCceFragmentControl": False,
                "actUpperThrAckNackFiltering": True,
                "actUpperThrAckNackHrFiltering": True,
                "bwpDN": "MRBTS-80/NRBTS-80/BWP_PROFILE-21000"
            }
        ]
    }
]

# Transform bwp into the desired JSON format
json_bwp = []
for item in bwp:
    json_item = {
        "distName": item["dist_name"],
        "operation": "update",
        "parameters": [
            {
                "parameterName": item["parameter"],
                "value": [
                    {
                        **value,
                        "cellBwpId": str(idx),
                        "pdcchResourcePreference": "peakRate"
                    } for idx, value in enumerate(item["value"])
                ],
                "operation": "update"
            }
        ]
    }
    json_bwp.append(json_item)

# Save the JSON to a file
output_file = 'test_bwp.json'
with open(output_file, 'w') as json_file:
    json.dump(json_bwp, json_file, indent=4)

print(f"JSON file '{output_file}' has been created and contains the transformed data.")