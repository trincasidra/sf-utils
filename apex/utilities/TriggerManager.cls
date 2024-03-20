public with sharing class TriggerManager {

    private static TriggerManager instance;
    private Boolean skipAll = false;
    private Set<System.Type> skipThese = new Set<System.Type>();

    public static TriggerManager getInstance() {
        if(instance == null) instance = new TriggerManager();
        return instance;
    }

    public static Boolean shouldRun(System.Type classToBypass) {
        return !getInstance().skipAll && !getInstance().skipThese.contains(classToBypass);
    }

    public static void bypassAll() {
        getInstance().skipAll = true;
    }

    public static void bypass(System.Type classToBypass) {
        getInstance().skipThese.add(classToBypass);
    }

    public static void reset() {
        getInstance().skipAll = false;
        getInstance().skipThese.clear();
    }
}
