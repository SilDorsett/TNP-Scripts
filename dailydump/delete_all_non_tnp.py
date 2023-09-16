import sys
from xml.etree import ElementTree as ET

if len(sys.argv) < 2:
    print("Usage: python delete_all_non_tnp.py <TODAY>")
    sys.exit(1)

today = sys.argv[1]
input_file = "/mnt/nationstates/nations/nations." + today + ".xml"
output_file = "/mnt/nationstates/nations_tnp/nations_tnp." + today + ".xml"

with open(output_file, "w") as output:
    output.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    output.write("<NATIONS>\n")
    for event, element in ET.iterparse(input_file, events=("start", "end")):
        if event == "end" and element.tag == "NATION":
            if element.find("REGION").text == "The North Pacific":
                output.write(ET.tostring(element, encoding="unicode"))
            element.clear()
    output.write("</NATIONS>\n")
