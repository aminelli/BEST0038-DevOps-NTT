package com.corso.devops.corsontt38.controller;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

/**
 * Unit test semplici per HomeController.
 * Testa la logica dei controller senza avviare il server.
 */
class HomeControllerSimpleTest {

    private HomeController controller;
    private Model model;

    @BeforeEach
    void setUp() {
        controller = new HomeController();
        model = new ConcurrentModel();
    }

    @Test
    void home_shouldReturnIndexView() {
        String viewName = controller.home(model);
        
        assertThat(viewName).isEqualTo("index");
    }

    @Test
    void home_shouldSetPageTitle() {
        controller.home(model);
        
        assertThat(model.getAttribute("pageTitle")).isEqualTo("Home");
    }

    @Test
    void home_shouldSetWelcomeMessage() {
        controller.home(model);
        
        assertThat(model.getAttribute("welcomeMessage"))
            .isEqualTo("Benvenuto nell'applicazione Spring Boot!");
    }

    @Test
    void about_shouldReturnAboutView() {
        String viewName = controller.about(model);
        
        assertThat(viewName).isEqualTo("about");
    }

    @Test
    void about_shouldSetPageTitle() {
        controller.about(model);
        
        assertThat(model.getAttribute("pageTitle")).isEqualTo("About");
    }

    @Test
    void about_shouldSetProjectName() {
        controller.about(model);
        
        assertThat(model.getAttribute("projectName"))
            .isEqualTo("Corso NTT 38 - Spring Boot Application");
    }

    @Test
    void about_shouldSetTechnologies() {
        controller.about(model);
        
        String[] technologies = (String[]) model.getAttribute("technologies");
        
        assertThat(technologies).isNotNull();
        assertThat(technologies).hasSize(6);
        assertThat(technologies).contains("Java 21", "Spring Boot 4.0.x", "Thymeleaf");
    }

    @Test
    void about_shouldSetDescription() {
        controller.about(model);
        
        String description = (String) model.getAttribute("description");
        
        assertThat(description).isNotNull();
        assertThat(description).contains("Applicazione web dimostrativa");
        assertThat(description).contains("Spring Boot");
    }
}
