
# CodeHover

<!-- badges: start -->
<!-- badges: end -->

Pipes are an excellent way to code for they make it easy to follow the code chain of transformations and theis results. 

The CodeHover aims to make it easy to create a HTML table with a simple hover effect (JQuery + CSS) that shows images just bellow this table.

This way one could set up lines of code in the table and a series of images showing the intermediary results of the code.

## Installation

You can install the experimental version of CodeHover from github:

``` r
install.packages("devtools")
devtools::install_github("arthurwelle/CodeHover")
```

# Example

Let´s try to replicate the following graph.

```{r, eval=TRUE, echo=TRUE}
ggplot() +
  geom_point(data = cars,
             aes(x = speed, 
                 y = dist,
                 color = 'red')) +
  scale_y_continuous(limits = c(0,100)) +
  labs(title = 'A ggplot fot the rest of us',
       subtitle = 'Testing a way of explicit showing the R workflow') +
  theme_bw()
  
```

Save every step as an image.

```{r, eval=FALSE, echo=TRUE}
g <- ggplot2::ggplot() +
  geom_point(data = cars,
             aes(x = speed, 
                 y = dist))

ggplot2::ggsave("./IMG/1b.png", width = 4, height = 3) 

g <-  g + aes(color = "red")
ggplot2::ggsave("./IMG/2b.png", width = 4, height = 3) 

g <-  g + scale_y_continuous(limits = c(0,100))
ggplot2::ggsave("./IMG/3b.png", width = 4, height = 3) 

g <-  g + labs(title = "A ggplot fot the rest of us")
ggplot2::ggsave("./IMG/4b.png", width = 4, height = 3) 

g <-  g + labs(subtitle = "Testing a way of explicit showing the R workflow")
ggplot2::ggsave("./IMG/5b.png", width = 4, height = 3) 

g <-  g + theme_bw()
ggplot2::ggsave("./IMG/6b.png", width = 4, height = 3) 

```

Create a table using **ch_int()**, **ch_row()**, and **ch_out()**.

```{r, echo=TRUE}
result <- ch_int(type = "incremental") %>% 
          ch_row(text = 
                     "ggplot() + 
                      <br> <tab1> geom_point(data = cars, </tab1>
                      <br> <tab2> aes(x = speed, </tab2>
                      <br> <tab2> &nbsp; &nbsp; y = dist, </tab2>",
                   img ="./IMG/1b.png") %>% 
          ch_row(text = "<tab2> color = 'red')) + </tab2>",
                   img ="./IMG/2b.png") %>%   
          ch_row(text = "<tab1> scale_y_continuous(limits = c(0,100)) + </tab1>",
                   img ="./IMG/3b.png") %>% 
          ch_row(text = "<tab1> labs(title = 'A ggplot fot the rest of us', </tab1>",
                   img ="./IMG/4b.png") %>%   
          ch_row(text = "<tab2> subtitle = 'Testing a way of explicit showing the R workflow') + </tab2>",
                   img ="./IMG/5b.png") %>% 
          ch_row(text = "<tab1>  theme_bw()</tab1> ",
                   img ="./IMG/6b.png") %>%
          ch_out(img_holder = "./IMG/1b.png") 
  
```

Call the table into the html.

```{r, echo=TRUE}
htmltools::HTML(result)

```

![](Example.gif) 


# Usage 

## Quotes

From <a href="https://stat.ethz.ch/R-manual/R-patched/library/base/html/Quotes.html">Quotes {base}</a> we see than "single quotes are normally only used to delimit character constants containing double quotes". This is the exactlly use here, we have to use single quotes in the R code that we want to pass as text for the HTML table.

For exemple, if we want to pass a ggplot2 title we could interchangebly use labs(title = "A Title") or labs(title = 'A Title'), but if we want to pass this as text to CodeHover we should use single quotes. 

  ch_row(text = "labs(title = 'A Title')",
         img ="img.png") %>% 
         
## Identation         

You can use the <br> tag to initiate new lines.

And to proper ident your text, as you would like to do to a code, you can use the HTML non-breaking spaces.

&amp;nbsp; a single non-breaking space;

&amp;ensp; —— it is equal to two &nbsp;

&amp;emsp; —— it is equal to four &nbsp;

Alternatively the CodeHover CSS has the tags &lt;tab1> to &lt;tab16> to denote 1 to 16 tabs (each tab is 4 spaces). To use it you have to enclose the text in those tags. For example:

ch_row(text = "&lt;tab7>theme_bw()&lt;/tab7>")


# JQuery/Javascript

For reference here is the JS code for the hover.


``` js
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>

<script>
$('.pipehover_incremental tr').hover(function() {
  $(this).removeClass()
  $(this).prevAll().removeClass()
  $(this).nextAll().removeClass()
  $(this).addClass('hover');
  $(this).prevAll().addClass('hover');
  $(this).closest('div').next().find('img').attr("src", $(this).attr("link"));
});


$('.pipehover_select_one_row tr').hover(function() {
  $(this).removeClass()
  $(this).prevAll().removeClass()
  $(this).nextAll().removeClass()
  $(this).addClass('hover');
  $(this).closest('div').next().find('img').attr("src", $(this).attr("link"));
});

</script>
```
