/*
 * Copyright (c) 2021. This code was written by Mehmet Yaz. Mehmet Yaz does not accept the problems that may arise due to these codes.
 */

package dev.styledart.liveTemplates;


import com.intellij.codeInsight.template.TemplateActionContext;
import com.intellij.codeInsight.template.TemplateContextType;
import org.jetbrains.annotations.NotNull;

public class StyleDartContext extends TemplateContextType {
    protected StyleDartContext() {
        super("DART_TOPLEVEL", "Top-level");
    }
    @Override
    public boolean isInContext(@NotNull TemplateActionContext templateActionContext) {
        return templateActionContext.getFile().getName().endsWith(".dart");
    }
}
