public  class Profiles {

    public static final Map<Id, Profile> byId;
    public static final Map<String, Profile> byName;

    static {
        Map<Id, Profile> profilesById = new Map<Id, Profile>();
        Map<String, Profile> profilesByName = new Map<String, Profile>();

        List<Profile> allProfiles = [SELECT Id, Name FROM Profile];
        for (Profile p : allProfiles) {
            profilesById.put(p.Id, p);
            profilesByName.put(p.Name, p);
        }

        byId = profilesById;
        byName = profilesByName;
    }
}
