library(dplyr)
library(plotly)
library(reshape2)

ui <- fluidPage(
  br(),
  br(),
  sidebarLayout(
  
  sidebarPanel(wellPanel(
    sliderInput("i_mul", "Intercept", min = -4,
                max = 4, step = 1, value = .5),
    sliderInput("s1_mul", "Slope x1", min = -6,
                max = 6, step = 1, value = -1),
    sliderInput("s2_mul", "Slope x2", min = -6,
                max = 6, step = 1, value = -1)),
    br(),
    br(),
    
    textOutput("userguess_mul")),
  
  
  mainPanel(plotlyOutput("reg_mul"))
  
))

server <- function(input,output){
  output$userguess_mul <- renderText({
    
    a <- input$i_mul
    b1 <- input$s1_mul
    b2 <- input$s2_mul
    paste0("Your guess:\n y = ", a, " + ", b1, " * (x1)", " + ", b2, " * (x2)")
    
  })
  
  output$reg_mul <- renderPlotly({
    set.seed(19)
    x1 <- rnorm(n = 20, mean = 2, sd = 2)
    x2 <- rnorm(n = 20, mean = 2, sd = 2)
    
    a_true <- -2
    b1_true <- 3
    b2_true <- -1
    y <- a_true + b1_true*x1 + b2_true*x2 + rnorm(n = 20, mean = 0, sd = 1)
    
    
    possible_x1 <- c(min(x1)-1, max(x1)+1) # only need 4 pts total
    possible_x2 <- c(min(x2)-1, max(x2)+1)
    
    # a = intercept, b = slope (user input)
    a <- input$i_mul
    b1 <- input$s1_mul
    b2 <- input$s2_mul
    
    surf <- data.frame(a = rep(possible_x1, each = length(possible_x2)),
                       b = rep(possible_x2, times = length(possible_x1)))
    surf <- cbind(surf, mapply(function(x_, x__){a + b1*x_ + b2 * x__}, surf$a, surf$b))#compute surface
    surf_matrix <- acast(surf, formula = a ~ b) #make matrix for surface
    
    
    #plot
    
    axx <- list(
      title = "X1",
      range = c(-2, 9)
    )
    
    axy <- list(
      title = "X2",
      range = c(-2, 9)
    )
    
    axz <- list(
      title = "Y",
      range = c(-15, 15)
    )
    
    scene = list(
      xaxis = axx,
      yaxis = axy,
      zaxis = axz, 
      aspectmode = "cube")
    
    if ((a == a_true) && (b1 == b1_true) && (b2 == b2_true)){
      plot_ly(x = possible_x1, y = possible_x2, z = surf_matrix)  %>%
        add_surface(name = "Regression Plane", hoverinfo = 'name', opacity = .5, surfacecolor = rep('green', length(possible_x1))) %>%
        hide_colorbar()%>%
        add_markers(x = x2, y = x1, z = y, data = df,
                    name = "Observed Data", hoverinfo = 'name', inherit = F,
                    marker = list(color = 'lightgreen', size = 5), opacity = .5) %>%
        layout(title = "Multivariate Regression", scene = scene)
    } else {
      plot_ly(x = possible_x1, y = possible_x2, z = surf_matrix)  %>%
        add_surface(name = "Regression Plane", hoverinfo = 'name', opacity = .5, surfacecolor = rep('red', length(possible_x1))) %>%
        hide_colorbar()%>%
        add_markers(x = x2, y = x1, z = y, data = df,
                    name = "Observed Data", hoverinfo = 'name',
                    marker = list(color = 'red', size = 5), opacity = .5) %>%
        layout(title = "\nMultivariate Regression", scene = scene)
    }
    
  })
}

shinyApp(ui = ui, server = server)