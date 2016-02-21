<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>TM_Update_Email</fullName>
        <field>Email__c</field>
        <formula>Contact__r.Email</formula>
        <name>TM - Update Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TM_Update_FirstName</fullName>
        <field>First_Name__c</field>
        <formula>Contact__r.FirstName</formula>
        <name>TM - Update Fiirst Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TM_Update_GitHubHandle</fullName>
        <field>Github_Handle__c</field>
        <formula>Contact__r.GitHub_Handle__c</formula>
        <name>TM - Update GitHub Handle</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TM_Update_LastName</fullName>
        <field>Last_Name__c</field>
        <formula>Contact__r.LastName</formula>
        <name>TM - Update Last Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Team Member  info from Contact</fullName>
        <actions>
            <name>TM_Update_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TM_Update_FirstName</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TM_Update_GitHubHandle</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TM_Update_LastName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISNULL(Contact__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
