package com.corso.devops.corsontt38.controller;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.ui.ConcurrentModel;
import org.springframework.ui.Model;

/**
 * Unit test semplici per PrivateAreaController.
 * Testa la logica del controller senza avviare il server.
 */
class PrivateAreaControllerSimpleTest {

    private PrivateAreaController controller;
    private Model model;
    private Authentication authentication;

    @BeforeEach
    void setUp() {
        controller = new PrivateAreaController();
        model = new ConcurrentModel();
        authentication = mock(Authentication.class);
    }

    @Test
    void dashboard_shouldReturnDashboardView() {
        when(authentication.getName()).thenReturn("testuser");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        String viewName = controller.dashboard(authentication, model);
        
        assertThat(viewName).isEqualTo("private/dashboard");
    }

    @Test
    void dashboard_shouldSetPageTitle() {
        when(authentication.getName()).thenReturn("testuser");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        assertThat(model.getAttribute("pageTitle")).isEqualTo("Dashboard");
    }

    @Test
    void dashboard_shouldSetUsername() {
        when(authentication.getName()).thenReturn("mario");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        assertThat(model.getAttribute("username")).isEqualTo("mario");
    }

    @Test
    void dashboard_shouldSetUserRoles() {
        when(authentication.getName()).thenReturn("testuser");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        String userRoles = (String) model.getAttribute("userRoles");
        assertThat(userRoles).contains("ROLE_USER");
    }

    @Test
    void dashboard_shouldSetMultipleRoles() {
        when(authentication.getName()).thenReturn("admin");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(
                new SimpleGrantedAuthority("ROLE_USER"),
                new SimpleGrantedAuthority("ROLE_ADMIN")
            )
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        String userRoles = (String) model.getAttribute("userRoles");
        assertThat(userRoles).contains("ROLE_USER");
        assertThat(userRoles).contains("ROLE_ADMIN");
    }

    @Test
    void dashboard_shouldSetWelcomeMessage() {
        when(authentication.getName()).thenReturn("mario");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        String welcomeMessage = (String) model.getAttribute("welcomeMessage");
        assertThat(welcomeMessage).isEqualTo("Benvenuto nella tua area riservata, mario!");
    }

    @Test
    void dashboard_shouldSetLoginTime() {
        when(authentication.getName()).thenReturn("testuser");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        assertThat(model.getAttribute("loginTime")).isNotNull();
    }

    @Test
    void dashboard_shouldSetIsAuthenticated() {
        when(authentication.getName()).thenReturn("testuser");
        when(authentication.getAuthorities()).thenReturn(
            (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        assertThat(model.getAttribute("isAuthenticated")).isEqualTo(true);
    }

    @Test
    void dashboard_shouldHandleDifferentUsernames() {
        String[] usernames = {"user", "admin", "mario", "testuser123"};
        
        for (String username : usernames) {
            Model localModel = new ConcurrentModel();
            when(authentication.getName()).thenReturn(username);
            when(authentication.getAuthorities()).thenReturn(
                (List) List.of(new SimpleGrantedAuthority("ROLE_USER"))
            );
            when(authentication.isAuthenticated()).thenReturn(true);

            controller.dashboard(authentication, localModel);
            
            assertThat(localModel.getAttribute("username")).isEqualTo(username);
            String welcomeMessage = (String) localModel.getAttribute("welcomeMessage");
            assertThat(welcomeMessage).contains(username);
        }
    }

    @Test
    void dashboard_shouldFormatRolesCorrectly() {
        when(authentication.getName()).thenReturn("admin");
        List<GrantedAuthority> authorities = List.of(
            new SimpleGrantedAuthority("ROLE_USER"),
            new SimpleGrantedAuthority("ROLE_ADMIN"),
            new SimpleGrantedAuthority("ROLE_MODERATOR")
        );
        when(authentication.getAuthorities()).thenReturn((List) authorities);
        when(authentication.isAuthenticated()).thenReturn(true);

        controller.dashboard(authentication, model);
        
        String userRoles = (String) model.getAttribute("userRoles");
        
        // Roles should be joined with comma and space
        assertThat(userRoles).contains("ROLE_USER");
        assertThat(userRoles).contains("ROLE_ADMIN");
        assertThat(userRoles).contains("ROLE_MODERATOR");
    }
}
