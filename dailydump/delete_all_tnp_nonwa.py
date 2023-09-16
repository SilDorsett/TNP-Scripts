import sys
from xml.etree import ElementTree as ET

if len(sys.argv) < 2:
    print("Usage: python delete_all_tnp_nonwa.py <TODAY>")
    sys.exit(1)

today = sys.argv[1]
input_file = "/mnt/nationstates/nations_tnp/nations_tnp." + today + ".xml"
output_file = "/mnt/nationstates/nations_tnp_wa/nations_tnp_wa." + today + ".xml"

with open(output_file, "w") as output:
    output.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    output.write("<NATIONS>\n")
    for event, element in ET.iterparse(input_file, events=("start", "end")):
        if event == "end" and element.tag == "NATION":
            unstatus_element = element.find("UNSTATUS")
            if unstatus_element is None or (
                unstatus_element.text in ("WA Member", "WA Delegate")
            ):
                output.write(ET.tostring(element, encoding="unicode"))
            element.clear()
    output.write("</NATIONS>\n")
