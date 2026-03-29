package com.corso.devops.corsontt38.controller;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

/**
 * Unit test semplici per AuthController.
 * Testa la logica del controller senza avviare il server.
 */
class AuthControllerSimpleTest {

    private AuthController controller;
    private Model model;

    @BeforeEach
    void setUp() {
        controller = new AuthController();
        model = new ConcurrentModel();
    }

    @Test
    void login_shouldReturnLoginView() {
        String viewName = controller.login(null, null, model);
        
        assertThat(viewName).isEqualTo("login");
    }

    @Test
    void login_shouldSetPageTitle() {
        controller.login(null, null, model);
        
        assertThat(model.getAttribute("pageTitle")).isEqualTo("Login");
    }

    @Test
    void login_shouldSetHelpMessage() {
        controller.login(null, null, model);
        
        String helpMessage = (String) model.getAttribute("helpMessage");
        
        assertThat(helpMessage).isNotNull();
        assertThat(helpMessage).contains("user/user123");
        assertThat(helpMessage).contains("admin/admin123");
        assertThat(helpMessage).contains("mario/mario123");
    }

    @Test
    void login_withErrorParameter_shouldSetErrorMessage() {
        controller.login("true", null, model);
        
        String errorMessage = (String) model.getAttribute("errorMessage");
        
        assertThat(errorMessage).isNotNull();
        assertThat(errorMessage).contains("Nome utente o password non validi");
    }

    @Test
    void login_withoutErrorParameter_shouldNotSetErrorMessage() {
        controller.login(null, null, model);
        
        assertThat(model.getAttribute("errorMessage")).isNull();
    }

    @Test
    void login_withLogoutParameter_shouldSetLogoutMessage() {
        controller.login(null, "true", model);
        
        String logoutMessage = (String) model.getAttribute("logoutMessage");
        
        assertThat(logoutMessage).isNotNull();
        assertThat(logoutMessage).contains("Logout effettuato con successo");
    }

    @Test
    void login_withoutLogoutParameter_shouldNotSetLogoutMessage() {
        controller.login(null, null, model);
        
        assertThat(model.getAttribute("logoutMessage")).isNull();
    }

    @Test
    void login_withBothParameters_shouldSetBothMessages() {
        controller.login("error", "logout", model);
        
        assertThat(model.getAttribute("errorMessage")).isNotNull();
        assertThat(model.getAttribute("logoutMessage")).isNotNull();
        assertThat(model.getAttribute("helpMessage")).isNotNull();
    }
}
