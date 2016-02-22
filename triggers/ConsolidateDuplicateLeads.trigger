/*  
  Created by: Ron Kiker 23-Nov-15
*/
trigger ConsolidateDuplicateLeads on Lead (
  before insert, after insert, 
  before update, after update, 
  before delete, after delete) 
{
if(CheckRecursive.runOnce()){
  if(Trigger.isBefore){

    if(Trigger.isInsert) {
    }
    if(Trigger.isUpdate) {

    }
    if(Trigger.isDelete) 
    {

    }
  }
}
  /***************************************************/
  if(Trigger.isAfter){

    if(Trigger.isInsert) {
 
    }

    if(Trigger.isUpdate) {

    }

    if(Trigger.isDelete) {
     
    }
  }


}