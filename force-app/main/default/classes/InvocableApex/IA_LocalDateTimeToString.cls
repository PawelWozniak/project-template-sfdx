/**
 * @author      Paweł Woźniak
 * @created     2022-09-16
 * @description Invocable Apex for Flows that converts given DateTime to String with timezone offset.
 * @see https://www.jamessimone.net/blog/joys-of-apex/organizing-invocable-and-static-code/
 */

public class IA_LocalDateTimeToString {

    @InvocableMethod(label = 'Convert DateTime To String'
                     description = 'Converts given DateTime to String with timezone offset'
                     category = 'Data Conversion'
                     callout = false)

    public static List<OutputToFlow> convertDateTimeToString(List<InputFromFlow> flowInputs) {
        List<OutputToFlow> outputs = new List<OutputToFlow>();

        for (InputFromFlow oneInput : flowInputs) {
            OutputToFlow output = new OutputToFlow();

            if (oneInput.givenDateTime == null) {
                output.isSuccess = false;
                output.errorMessage = 'Required input was empty';
            }
            else {
                output.dateAsString = oneInput.givenDateTime.format();
            }

            outputs.add(output);
        }

        return outputs;
    }

    /**
     * @description Data format of input passed from Flow
     */
    public class InputFromFlow {
        @InvocableVariable(label = 'Input DateTime'
                           description = 'DateTime to be converted to String'
                           required = true)
        public DateTime givenDateTime;

    }

    /**
     * @description Data format of output passed back to Flow
     */
    public class OutputToFlow {
        public OutputToFlow() {
            this.isSuccess = true;
            this.errorMessage = '';
            this.dateAsString = '';
        }

        @InvocableVariable(label = 'Is Success'
                           description = '')
        public Boolean isSuccess;

        @InvocableVariable(label = 'Error Message'
                           description = 'Error message in case something failed.')
        public String errorMessage;

        // Here add your variables
        @InvocableVariable(label = 'Date String'
                           description = 'Date converted to string.')
        public String dateAsString;
    }

}