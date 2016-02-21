global class ScheduleStoreRefreshToken implements Schedulable {
    public Id srId;

    global ScheduleStoreRefreshToken(Id srId) {
        this.srId = srId;
    } 

    global void execute(SchedulableContext sc) {
        SignupRequestService.storeRefreshToken(this.srId);
    }
}