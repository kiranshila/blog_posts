---
title: We Don't Need No Stinkin' Frontend
draft: false
date: 2023-06-18
tags:
  - clojure
---

I think I will never get tired of writing blogging software. I think I may enjoy it more than actually writing blog posts.

I have now written blogging software three times. The [first time](https://blog.kiranshila.com/post/clojure_blog) was a full-stack Clojure app using React through reagent (CLJS) in the front end and Jetty in the back end. This was fine but was kinda clunky. I learned a lot about web design in the process. The [second attempt](https://blog.kiranshila.com/post/no_backend) was "serverless" which did all the logic in the front end as a single page app. The idea was to get my markdown library, [cybermonday](https://github.com/kiranshila/cybermonday), working in CLJS through a JS markdown to IR library so the whole thing could run on GitHub Pages. This too worked, but was painfully slow. It took on average 3 seconds to render a page. Also, it was quite a complex piece of software. It intercepted GET requests to the static markdown resources and dynamically rendered the markdown into React components.

In what I hope to be the last rewrite (lol), I have finished writing a version of the site that is "backend-only". After reading [hypermedia propaganda](https://htmx.org/), I see now that sending HTML to represent HTML probably is the simplest and most effective way to create websites. In this vein, I found a new Clojure web framework [biff](https://biffweb.com/) that utilizes [rum](https://github.com/tonsky/rum) to template HTML and utilizes HTMX to manage the dynamic aspects of the site. Seeing how clean this server-only structure worked gave me the kick in the pants I needed to do this rewrite.

In the case of this blog, however, I don't need any dynamism or state at all (otherwise I probably would have used Biff); it's all just static markdown after all. So, the idea was to use rum to create all the HTML views, cybermonday to pre-render all the markdown to hiccup, and [http-kit](https://github.com/http-kit/http-kit) to serve the content. Finally, my friend [Luciano](https://luciano.laratel.li/) told me about [fly.io](https://fly.io/), which will host small-scale web servers for free. This all seemed like the perfect combination for an even smaller footprint, performant website.

So, I wrote this new site over the weekend. Not only is it less than 300 lines of Clojure in total (half of the previous versions, mainly because there is now no state to manage), it is significantly more performant. Every page loads in less than 100 ms.

## Graal

One of the neat things I did to make things even faster, was to use [graal native-image](https://www.graalvm.org/22.0/reference-manual/native-image/) to create a minimal lightweight static executable for the server. I had to fix a few reflection violations in cybermonday, but the resulting executable is ~60MB. The whole thing is built with Docker and deployed to fly using GitHub actions, it's all pretty seamless.

The code for all this can be found [here](https://github.com/kiranshila/bljog2), please open any bugs if you run into anything. Thanks for reading!