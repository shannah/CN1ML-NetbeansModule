package ca.weblite.codename1.cn1ml.demos;


import com.codename1.ui.Command;
import com.codename1.ui.Component;
import com.codename1.ui.Display;
import com.codename1.ui.Form;
import com.codename1.ui.Label;
import com.codename1.ui.events.ActionEvent;
import com.codename1.ui.events.ActionListener;
import com.codename1.ui.layouts.BorderLayout;
import com.codename1.ui.plaf.UIManager;
import com.codename1.ui.util.Resources;
import java.io.IOException;
import java.util.HashMap;

public class CN1MLDemo {

    private Form current;
    private Resources theme;
    public void init(Object context) {
        try {
            theme = Resources.openLayered("/theme");
            UIManager.getInstance().setThemeProps(theme.getTheme(theme.getThemeResourceNames()[0]));
        } catch(IOException e){
            e.printStackTrace();
        }
        // Pro users - uncomment this code to get crash reports sent to you automatically
        /*Display.getInstance().addEdtErrorHandler(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                evt.consume();
                Log.p("Exception in AppName version " + Display.getInstance().getProperty("AppVersion", "Unknown"));
                Log.p("OS " + Display.getInstance().getPlatformName());
                Log.p("Error " + evt.getSource());
                Log.p("Current Form " + Display.getInstance().getCurrent().getName());
                Log.e((Throwable)evt.getSource());
                Log.sendLog();
            }
        });*/
    }
    
    public void start() {
        if(current != null){
            current.show();
            return;
        }
       showMainMenu();
    }

    private Form createForm(String title, Component content){
        Form f = new Form(title);
        f.setLayout(new BorderLayout());
        f.addComponent(BorderLayout.CENTER, content);
        if (!"Main Menu".equals(title)){
            f.setBackCommand(new Command("Main Menu"){

                @Override
                public void actionPerformed(ActionEvent evt) {
                    createForm("Main Menu", getMainMenu()).showBack();
                }

            });
        }   
        return f;
    }
    
    private Component getMainMenu(){
        HashMap context = new HashMap();
        context.put("res", theme);
        context.put("menuItems", new String[]{
            "Simple List",
            "Contact Form",
            "Map",
            "Web Browser"
        });
        final MainMenu m = new MainMenu(context);
        m.getMenuList().addActionListener(new ActionListener(){

            public void actionPerformed(ActionEvent evt) {
                String sel = (String)m.getMenuList().getSelectedItem();
                if ("Simple List".equals(sel)){
                    showSimpleList();
                } else if ( "Contact Form".equals(sel)){
                    showContactForm();
                } else if ("Map".equals(sel)){
                    showMap();
                } else if ("Web Browser".equals(sel)){
                    showWebBrowser();
                }
            }
            
        });
        
        return m.getRoot();
        
    }
    
    private void showMainMenu(){
        createForm("CN1ML Demos", getMainMenu()).show();
    }
    
    private void showSimpleList(){
        SimpleList l = new SimpleList(newContext());
        
        createForm("Simple List", l.getRoot()).show();
    }
    
    private HashMap newContext(){
        HashMap context = new HashMap();
        context.put("res", theme);
        return context;
    }
    
    private void showContactForm(){
        ContactForm f = new ContactForm(newContext());
        createForm("Contact Form", f.getRoot()).show();
    }
    
    private void showMap(){
        Map m = new Map(newContext());
        createForm("Map", m.getRoot()).show();
    }
    
    private void showWebBrowser(){
        WebBrowser m = new WebBrowser(newContext());
        createForm("Web Browser", m.getRoot()).show();
    }
    
    public void stop() {
        current = Display.getInstance().getCurrent();
    }
    
    public void destroy() {
    }

}
