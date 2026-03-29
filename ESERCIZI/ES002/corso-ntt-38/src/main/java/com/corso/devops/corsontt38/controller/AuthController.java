package com.corso.devops.corsontt38.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Controller per gestire l'autenticazione (login).
 */
@Controller
public class AuthController {

    /**
     * Gestisce la richiesta alla pagina di login.
     * Mostra messaggi di errore o successo basati sui parametri della query.
     * 
     * @param error parametro opzionale che indica un errore di login
     * @param logout parametro opzionale che indica un logout avvenuto con successo
     * @param model Model per passare dati alla view
     * @return nome del template Thymeleaf da renderizzare
     */
    @GetMapping("/login")
    public String login(
            @RequestParam(value = "error", required = false) String error,
            @RequestParam(value = "logout", required = false) String logout,
            Model model) {
        
        model.addAttribute("pageTitle", "Login");
        
        // Verifica se c'è stato un errore di login
        if (error != null) {
            model.addAttribute("errorMessage", 
                "Nome utente o password non validi. Riprova!");
        }
        
        // Verifica se l'utente ha appena fatto logout
        if (logout != null) {
            model.addAttribute("logoutMessage", 
                "Logout effettuato con successo!");
        }
        
        // Informazioni di aiuto per gli utenti di test
        model.addAttribute("helpMessage", 
            "Utenti di test: user/user123, admin/admin123, mario/mario123");
        
        return "login";
    }
}
