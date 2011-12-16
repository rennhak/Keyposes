#!/usr/bin/ruby

require 'rubygems'
require 'opengl'

include Gl,Glu,Glut

$light_diffuse = [1.0, 0.0, 0.0, 1.0]
$light_position = [1.0, 1.0, 1.0, 0.0]
$n = [ 
	[-1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [1.0, 0.0, 0.0],
	[0.0, -1.0, 0.0], [0.0, 0.0, 1.0], [0.0, 0.0, -1.0] ]
$faces = [
	[0, 1, 2, 3], [3, 2, 6, 7], [7, 6, 5, 4],
	[4, 5, 1, 0], [5, 6, 2, 1], [7, 4, 0, 3] ]
$v = 0

def drawBox
	for i in (0..5)
		glBegin(GL_QUADS)
		glNormal(*($n[i]))
		glVertex($v[$faces[i][0]])
		glVertex($v[$faces[i][1]])
		glVertex($v[$faces[i][2]])
		glVertex($v[$faces[i][3]])
		glEnd()
	end
end

display = Proc.new do
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	drawBox
#	glutSwapBuffers
end

def myinit
$v = [[-1, -1,1],[-1, -1,-1], [-1,1,-1], [-1,1,1], [1, -1,1],
	[1, -1,-1], [1, 1,-1], [1,1,1]]

	glLight(GL_LIGHT0, GL_DIFFUSE, $light_diffuse)
	glLight(GL_LIGHT0, GL_POSITION, $light_position)
	glEnable(GL_LIGHT0)
	glEnable(GL_LIGHTING)
	
	glEnable(GL_DEPTH_TEST)
	
	glMatrixMode(GL_PROJECTION)
	gluPerspective(40.0, 1.0, 1.0,  10.0)
	glMatrixMode(GL_MODELVIEW)
	gluLookAt(0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
	
	glTranslate(0.0, 0.0, -1.0)
	glRotate(60, 1.0, 0.0, 0.0)
	glRotate(-20, 0.0, 0.0, 1.0)
end

keyboard = Proc.new do |key, x, y|
	case (key)
		when ?\e
		exit(0);
	end
end

glutInit
glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
glutInitWindowSize(500, 500)
glutInitWindowPosition(100, 100)
glutCreateWindow("red 3D lighted cube")
glutDisplayFunc(display)

# http://ruby-opengl.rubyforge.org/svn/trunk/doc/tutorial.txt
# GL.TexImage2D( GL::TEXTURE_2D, 0, 3, 150, 150, 0, GL::RGB, GL::BYTE, @image)
target          = [ GL::TEXTURE_1D, GL::TEXTURE_2D, GL::TEXTURE_3D ]
level_of_detail = 0 # mipmap level
format          = [ GL::RED, GL::GREEN, GL::BLUE, GL::ALPHA, GL::RGB, GL::BGR, GL::RGBA, GL::BGRA, GL::LUMINANCE, GL::LUMINANCE_ALPHA ] # components per pixel
type            = [ GL::UNSIGNED_BYTE ] # component type

#pixels          = Gl.glGetTexImage( target[1], level_of_detail, format[4], type[0] )
#image           = Magick::Image.new( width, height )
#image.import_pixels( 0, 0, width, height, "RGB", pixels )

# packed data as string
pixels          = glGetTexImage( target[1], level_of_detail, GL::RGB, GL::FLOAT )

# now convert it to ruby array
texture = pixels.unpack("f*")

p pixels
p texture


glutKeyboardFunc(keyboard)
myinit
glutMainLoop()


