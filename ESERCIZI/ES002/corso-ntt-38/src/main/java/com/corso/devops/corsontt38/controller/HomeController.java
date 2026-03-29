package com.corso.devops.corsontt38.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

/**
 * Controller per gestire le pagine pubbliche dell'applicazione.
 */
@Controller
public class HomeController {

    /**
     * Gestisce la richiesta alla home page pubblica.
     * 
     * @param model Model per passare dati alla view
     * @return nome del template Thymeleaf da renderizzare
     */
    @GetMapping({"/", "/home"})
    public String home(Model model) {
        model.addAttribute("pageTitle", "Home");
        model.addAttribute("welcomeMessage", "Benvenuto nell'applicazione Spring Boot!");
        return "index";
    }

    /**
     * Gestisce la richiesta alla pagina About.
     * 
     * @param model Model per passare dati alla view
     * @return nome del template Thymeleaf da renderizzare
     */
    @GetMapping("/about")
    public String about(Model model) {
        model.addAttribute("pageTitle", "About");
        
        // Tecnologie utilizzate nel progetto
        String[] technologies = {
            "Java 21",
            "Spring Boot 4.0.x",
            "Spring Security 6",
            "Thymeleaf",
            "Bootstrap 5",
            "Maven"
        };
        
        model.addAttribute("technologies", technologies);
        model.addAttribute("projectName", "Corso NTT 38 - Spring Boot Application");
        model.addAttribute("description", 
            "Applicazione web dimostrativa realizzata con Spring Boot. " +
            "Include sistema di autenticazione, aree pubbliche e private, " +
            "e un'interfaccia responsive realizzata con Bootstrap.");
        
        return "about";
    }
}
