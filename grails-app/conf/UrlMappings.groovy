class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

                        // landing page
                        "/"(controller: 'project', action: 'index')

		"500"(view:'/error')
	}
}
