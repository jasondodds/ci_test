public with sharing class EnvironmentService {
    public static void setEnvironmentBranchName(List<Environment__c> envs) {
        String message;
        for(Environment__c env : envs) {
            if(String.isBlank(env.Branch_Name__c)){
                if(env.Name == 'Packaging') {
                    message = 'master';
                    env.Branch_Name__c = 'master';
                }
                else{
                    message = env.Name;
                }
            }
            else {
                message = env.Branch_Name__c;
            }

            String regex = '[^\\w]';
            Pattern regexPattern = Pattern.compile(regex);
            Matcher regexMatcher = regexPattern.matcher(message);
            if(regexMatcher.find()) {
               message = message.replaceAll(regex, '_');
            }

            env.Branch_Name__c = message.toLowerCase();
            system.debug('BRANCH NAME ' + env.Branch_Name__c);
        }
    }
}