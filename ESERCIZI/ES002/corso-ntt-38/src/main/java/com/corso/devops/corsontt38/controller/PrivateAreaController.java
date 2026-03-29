package com.corso.devops.corsontt38.controller;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.stream.Collectors;

/**
 * Controller per gestire l'area privata dell'applicazione.
 * Accessibile solo agli utenti autenticati.
 */
@Controller
@RequestMapping("/private")
public class PrivateAreaController {

    /**
     * Gestisce la richiesta alla dashboard privata.
     * Mostra informazioni personalizzate sull'utente loggato.
     * 
     * @param authentication oggetto Authentication contenente i dettagli dell'utente
     * @param model Model per passare dati alla view
     * @return nome del template Thymeleaf da renderizzare
     */
    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication, Model model) {
        model.addAttribute("pageTitle", "Dashboard");
        
        // Ottiene il nome utente dall'oggetto Authentication
        String username = authentication.getName();
        model.addAttribute("username", username);
        
        // Ottiene i ruoli dell'utente
        String roles = authentication.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .collect(Collectors.joining(", "));
        model.addAttribute("userRoles", roles);
        
        // Messaggio di benvenuto personalizzato
        model.addAttribute("welcomeMessage", 
            "Benvenuto nella tua area riservata, " + username + "!");
        
        // Informazioni aggiuntive
        model.addAttribute("loginTime", new java.util.Date());
        model.addAttribute("isAuthenticated", authentication.isAuthenticated());
        
        return "private/dashboard";
    }
}
