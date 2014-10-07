package org.jsoup.helper;

import org.jsoup.Jsoup;
import org.junit.Test;

import java.util.Arrays;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class FormatTest {

    @Test public void formatAttribute() {
        assertEquals("set:URL", Format.formatAttributeName("set:URL"));
        assertEquals("foo:bar", Format.formatAttributeName("foo:BAR"));
        assertEquals("data-BAr", Format.formatAttributeName("data-BAr"));
    }

}
