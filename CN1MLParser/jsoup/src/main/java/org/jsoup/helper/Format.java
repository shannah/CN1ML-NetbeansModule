/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.jsoup.helper;

/**
 *
 * @author shannah
 */
public class Format {
    
    public static String formatAttributeName(String name){
        if ( name.indexOf("set:")==0 || name.indexOf("data-")==0 ){
            return name;
        } else {
            return name.toLowerCase();
        }
    }
}
