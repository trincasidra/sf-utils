import argparse
import csv
import xmltodict
from yattag import Doc, indent

field_dependencies = None


'''
field-meta.xml structure:
{
    CustomField:{
        @xmlnds,
        fullName,
        externalId,
        label,
        required,
        trackFeedHistory,
        trackTrending,
        type,
        valueSet:{
            controllingField,
            valueSetDefinition:{
                sorted,
                value:[{
                    fullName,
                    default,
                    label
                }]
            },
            valueSettings:[{
                controllingFieldValue, # String or String[]
                valueName
            }]
        }
    }
}
'''


def importXml(input_file):
    global field_dependencies
    with open(input_file, 'r') as xml_file:
        xml_string = xml_file.read()
        xml_dict = xmltodict.parse(xml_string)
        field_dependencies = xml_dict['CustomField']['valueSet']['valueSettings']


def exportCsv(output_file):
    export_rows = []
    for dependency in field_dependencies:
        row = [dependency['valueName']]
        if type(dependency['controllingFieldValue']) is list:
            row.extend(dependency['controllingFieldValue'])
        else:
            row.append(dependency['controllingFieldValue'])
        export_rows.append(row)

    # Fill our matrix with empty strings so that it is homogeneous and can be transposed
    maxLen = max(map(len, export_rows))
    for export_row in export_rows:
        export_row.extend([''] * (maxLen - len(export_row)))

    with open(output_file if output_file is not None else 'export.csv', 'w', newline='') as csv_file:
        file_writer = csv.writer(csv_file, delimiter='\t', escapechar='|', quoting=csv.QUOTE_MINIMAL)
        # Transpose csv so that depedencies are per-column
        file_writer.writerows(zip(*export_rows))


def importCsv(input_file):
    import_rows = []
    with open(input_file, newline='') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter='\t', quotechar='|')
        for row in csv_reader:
            import_rows.append(row)

    # Transpose
    import_rows = zip(*import_rows)

    global field_dependencies
    field_dependencies = {}
    for row in import_rows:
        field_dependencies[row[0]] = row[1:]



def exportXml(output_file):
    doc, tag, text = Doc().tagtext()

    with tag('valueSet'):
        for dependant_value, controlling_values in field_dependencies.items():
            with tag('valueSettings'):
                for controlling_value in controlling_values:
                    if controlling_value == '':
                        continue
                    with tag('controllingFieldValue'):
                        text(controlling_value)
                with tag('valueName'):
                    text(dependant_value)

    result = indent(
        doc.getvalue(),
        indentation = ' '*4,
        newline = '\r\n'
    )

    print(result, file=open(output_file if output_file is not None else 'export.xml', 'w'))


def main():
    parser = argparse.ArgumentParser('dependency-helper')
    parser.add_argument('input', help='File to read xml or csv input from.', type=str)
    parser.add_argument('-o', '--output', help='File to store the csv output to. Defaults to "export.csv" or "export.xml" if not provided.', type=str)
    args = parser.parse_args()
    if args.input.endswith('.field-meta.xml'):
        importXml(args.input)
        exportCsv(args.output)
    elif args.input.endswith('.csv'):
        importCsv(args.input)
        exportXml(args.output)
    else:
        print('Please provide a .field-meta.xml or .csv file!')

if __name__ == '__main__':
    main()
